import type { DbClient } from '../db/pool.js';
import type { ExtractedAudioTags, VerifiedSongMetadata } from '../types/metadata.js';
import { extractAudioTags } from './audioTagExtractor.js';
import { searchRecording, type MusicBrainzRecordingSearchResult } from './musicBrainzClient.js';
import { resolveArtwork } from './artworkResolver.js';
import { findArtistPortrait } from './theAudioDbClient.js';
import { textSimilarity, weightedScore } from '../utils/scoring.js';

function firstArtist(recording: MusicBrainzRecordingSearchResult) {
  return recording['artist-credit']?.find((credit) => credit.artist)?.artist;
}

function bestRelease(recording: MusicBrainzRecordingSearchResult, tags: ExtractedAudioTags) {
  const releases = recording.releases ?? [];
  if (releases.length === 0) throw new Error(`MusicBrainz recording ${recording.id} has no release/albums`);
  return [...releases].sort((a, b) => {
    const aScore = weightedScore([
      [textSimilarity(a.title, tags.album), 0.75],
      [a.status === 'Official' ? 1 : 0.4, 0.25]
    ]);
    const bScore = weightedScore([
      [textSimilarity(b.title, tags.album), 0.75],
      [b.status === 'Official' ? 1 : 0.4, 0.25]
    ]);
    return bScore - aScore;
  })[0];
}

function scoreRecording(recording: MusicBrainzRecordingSearchResult, tags: ExtractedAudioTags): number {
  const artist = firstArtist(recording);
  const titleScore = textSimilarity(recording.title, tags.title);
  const artistScore = textSimilarity(artist?.name, tags.artist);
  const mbScore = Math.min((recording.score ?? 0) / 100, 1);
  const durationScore = tags.durationMs && recording.length
    ? Math.max(0, 1 - Math.abs(tags.durationMs - recording.length) / Math.max(tags.durationMs, recording.length))
    : 0.7;

  return weightedScore([
    [titleScore, 0.38],
    [artistScore || 0.65, tags.artist ? 0.3 : 0.12],
    [durationScore, 0.17],
    [mbScore, 0.15]
  ]);
}

export async function verifySongMetadataFromFile(filePath: string): Promise<VerifiedSongMetadata> {
  const extracted = await extractAudioTags(filePath);
  const search = await searchRecording({
    title: extracted.title,
    artist: extracted.artist,
    album: extracted.album,
    limit: 8
  });

  const candidates = search.recordings
    .filter((recording) => firstArtist(recording) && recording.releases?.length)
    .map((recording) => ({ recording, confidence: scoreRecording(recording, extracted) }))
    .sort((a, b) => b.confidence - a.confidence);

  const best = candidates[0];
  if (!best || best.confidence < 0.72) {
    throw new Error(`No trustworthy MusicBrainz match for "${extracted.title}". Best confidence: ${best?.confidence ?? 0}`);
  }

  const artist = firstArtist(best.recording)!;
  const release = bestRelease(best.recording, extracted);
  const portrait = await findArtistPortrait(artist.name);
  const artwork = await resolveArtwork({
    releaseMbid: release.id,
    albumTitle: release.title,
    artistName: artist.name
  });

  return {
    recordingMbid: best.recording.id,
    title: best.recording.title,
    confidence: Number(best.confidence.toFixed(3)),
    artist: {
      mbid: artist.id,
      name: artist.name,
      sortName: artist['sort-name'],
      disambiguation: artist.disambiguation,
      portraitUrl: portrait.url
    },
    album: {
      mbid: release.id,
      title: release.title,
      artistMbid: artist.id,
      releaseDate: release.date,
      coverArtUrl: artwork.url
    },
    artworkUrl: artwork.url,
    artworkSource: artwork.source,
    extracted
  };
}

export async function persistVerifiedMetadata(db: DbClient, audioUri: string, metadata: VerifiedSongMetadata): Promise<string> {
  const client = 'connect' in db ? await db.connect() : db;
  const shouldRelease = 'connect' in db;

  try {
    await client.query('BEGIN');

    const artistResult = await client.query<{ id: string }>(
      `INSERT INTO artists (mbid, name, sort_name, disambiguation, portrait_url, portrait_source, raw_theaudiodb)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (mbid) DO UPDATE SET
         name = EXCLUDED.name,
         sort_name = EXCLUDED.sort_name,
         disambiguation = EXCLUDED.disambiguation,
         portrait_url = COALESCE(EXCLUDED.portrait_url, artists.portrait_url),
         updated_at = now()
       RETURNING id`,
      [metadata.artist.mbid, metadata.artist.name, metadata.artist.sortName, metadata.artist.disambiguation, metadata.artist.portraitUrl, metadata.artist.portraitUrl ? 'theaudiodb' : null, {}]
    );
    const artistId = artistResult.rows[0].id;

    const albumResult = await client.query<{ id: string }>(
      `INSERT INTO albums (mbid, artist_id, title, release_date, cover_art_url, cover_art_source)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (mbid) DO UPDATE SET
         artist_id = EXCLUDED.artist_id,
         title = EXCLUDED.title,
         release_date = EXCLUDED.release_date,
         cover_art_url = EXCLUDED.cover_art_url,
         cover_art_source = EXCLUDED.cover_art_source,
         updated_at = now()
       RETURNING id`,
      [metadata.album.mbid, artistId, metadata.album.title, metadata.album.releaseDate || null, metadata.album.coverArtUrl, metadata.artworkSource === 'theaudiodb-album' ? 'theaudiodb' : metadata.artworkSource]
    );
    const albumId = albumResult.rows[0].id;

    const audioFormat = (metadata.extracted.format ?? 'flac').toLowerCase().replace('mpeg', 'mp3');
    const songResult = await client.query<{ id: string }>(
      `INSERT INTO songs (
         recording_mbid, album_id, primary_artist_id, title, duration_ms, audio_uri, audio_format,
         is_lossless, artwork_url, artwork_source, metadata_confidence, raw_extracted_tags
       ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
       ON CONFLICT (recording_mbid) DO UPDATE SET
         album_id = EXCLUDED.album_id,
         primary_artist_id = EXCLUDED.primary_artist_id,
         title = EXCLUDED.title,
         duration_ms = EXCLUDED.duration_ms,
         audio_uri = EXCLUDED.audio_uri,
         audio_format = EXCLUDED.audio_format,
         is_lossless = EXCLUDED.is_lossless,
         artwork_url = EXCLUDED.artwork_url,
         artwork_source = EXCLUDED.artwork_source,
         metadata_confidence = EXCLUDED.metadata_confidence,
         raw_extracted_tags = EXCLUDED.raw_extracted_tags,
         updated_at = now()
       RETURNING id`,
      [
        metadata.recordingMbid,
        albumId,
        artistId,
        metadata.title,
        metadata.extracted.durationMs ?? null,
        audioUri,
        audioFormat,
        metadata.extracted.lossless,
        metadata.artworkUrl,
        metadata.artworkSource,
        metadata.confidence,
        metadata.extracted
      ]
    );

    await client.query(
      `INSERT INTO song_artists (song_id, artist_id, role, position)
       VALUES ($1, $2, 'primary', 1)
       ON CONFLICT DO NOTHING`,
      [songResult.rows[0].id, artistId]
    );

    await client.query('COMMIT');
    return songResult.rows[0].id;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    if (shouldRelease) client.release();
  }
}
