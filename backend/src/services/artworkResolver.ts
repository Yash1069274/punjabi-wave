import { fetch } from 'undici';
import { findAlbumCover, findArtistPortrait } from './theAudioDbClient.js';

const COVER_ART_BASE = 'https://coverartarchive.org/release';

async function coverArtArchiveFront(releaseMbid: string): Promise<string | undefined> {
  const response = await fetch(`${COVER_ART_BASE}/${releaseMbid}/front-500`, { method: 'HEAD' });
  if (response.ok) return `${COVER_ART_BASE}/${releaseMbid}/front-500`;
  return undefined;
}

export async function resolveArtwork(input: { releaseMbid: string; albumTitle: string; artistName: string }) {
  const coverArtUrl = await coverArtArchiveFront(input.releaseMbid);
  if (coverArtUrl) return { url: coverArtUrl, source: 'cover-art-archive' as const, albumRaw: null, artistRaw: null };

  const album = await findAlbumCover(input.artistName, input.albumTitle);
  if (album.url) return { url: album.url, source: 'theaudiodb-album' as const, albumRaw: album.raw, artistRaw: null };

  const artist = await findArtistPortrait(input.artistName);
  if (artist.url) return { url: artist.url, source: 'theaudiodb-artist-fallback' as const, albumRaw: album.raw, artistRaw: artist.raw };

  return {
    url: `https://api.dicebear.com/9.x/shapes/svg?seed=${encodeURIComponent(input.artistName)}`,
    source: 'generated-placeholder' as const,
    albumRaw: album.raw,
    artistRaw: artist.raw
  };
}
