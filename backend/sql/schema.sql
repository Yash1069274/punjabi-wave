BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS artists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mbid uuid NOT NULL UNIQUE,
  name text NOT NULL,
  sort_name text,
  disambiguation text,
  portrait_url text,
  portrait_source text CHECK (portrait_source IN ('theaudiodb', 'fanarttv', 'wikidata', 'manual-curated', 'generated-placeholder')),
  verification_state text NOT NULL DEFAULT 'verified' CHECK (verification_state IN ('verified', 'needs-review', 'rejected')),
  raw_musicbrainz jsonb NOT NULL DEFAULT '{}'::jsonb,
  raw_theaudiodb jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS albums (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mbid uuid NOT NULL UNIQUE,
  artist_id uuid NOT NULL REFERENCES artists(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  title text NOT NULL,
  release_date date,
  release_group_mbid uuid,
  cover_art_url text,
  cover_art_source text CHECK (cover_art_source IN ('cover-art-archive', 'theaudiodb', 'artist-fallback', 'generated-placeholder')),
  verification_state text NOT NULL DEFAULT 'verified' CHECK (verification_state IN ('verified', 'needs-review', 'rejected')),
  raw_musicbrainz jsonb NOT NULL DEFAULT '{}'::jsonb,
  raw_theaudiodb jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (id, artist_id),
  UNIQUE (mbid, artist_id)
);

CREATE TABLE IF NOT EXISTS songs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  recording_mbid uuid NOT NULL UNIQUE,
  album_id uuid NOT NULL,
  primary_artist_id uuid NOT NULL,
  title text NOT NULL,
  track_number integer CHECK (track_number IS NULL OR track_number > 0),
  disc_number integer NOT NULL DEFAULT 1 CHECK (disc_number > 0),
  duration_ms integer CHECK (duration_ms IS NULL OR duration_ms > 0),
  audio_uri text NOT NULL,
  audio_format text NOT NULL CHECK (audio_format IN ('flac', 'wav', 'aiff', 'alac', 'mp3', 'aac', 'ogg', 'opus')),
  is_lossless boolean NOT NULL DEFAULT false,
  artwork_url text NOT NULL,
  artwork_source text NOT NULL CHECK (artwork_source IN ('cover-art-archive', 'theaudiodb-album', 'theaudiodb-artist-fallback', 'artist-fallback', 'generated-placeholder')),
  metadata_confidence numeric(4,3) NOT NULL CHECK (metadata_confidence >= 0 AND metadata_confidence <= 1),
  verification_state text NOT NULL DEFAULT 'verified' CHECK (verification_state IN ('verified', 'needs-review', 'rejected')),
  raw_extracted_tags jsonb NOT NULL DEFAULT '{}'::jsonb,
  raw_musicbrainz jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT songs_album_artist_fk FOREIGN KEY (album_id, primary_artist_id)
    REFERENCES albums(id, artist_id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS song_artists (
  song_id uuid NOT NULL REFERENCES songs(id) ON UPDATE CASCADE ON DELETE CASCADE,
  artist_id uuid NOT NULL REFERENCES artists(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  role text NOT NULL DEFAULT 'performer' CHECK (role IN ('primary', 'featured', 'composer', 'producer', 'lyricist', 'performer')),
  position integer NOT NULL DEFAULT 1 CHECK (position > 0),
  PRIMARY KEY (song_id, artist_id, role)
);

CREATE TABLE IF NOT EXISTS lyrics (
  song_id uuid PRIMARY KEY REFERENCES songs(id) ON UPDATE CASCADE ON DELETE CASCADE,
  language_code text NOT NULL DEFAULT 'pa',
  lrc_text text NOT NULL,
  source text NOT NULL,
  synchronized boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS acoustic_features (
  song_id uuid PRIMARY KEY REFERENCES songs(id) ON UPDATE CASCADE ON DELETE CASCADE,
  tempo numeric(7,3),
  key_signature text,
  energy numeric(5,4) CHECK (energy IS NULL OR (energy >= 0 AND energy <= 1)),
  danceability numeric(5,4) CHECK (danceability IS NULL OR (danceability >= 0 AND danceability <= 1)),
  spectral_centroid numeric(12,4),
  mfcc_vector double precision[] NOT NULL DEFAULT '{}',
  embedding double precision[] NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS metadata_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  audio_uri text NOT NULL,
  status text NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'running', 'verified', 'needs-review', 'failed')),
  error_message text,
  verified_song_id uuid REFERENCES songs(id) ON UPDATE CASCADE ON DELETE SET NULL,
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS p2p_audio_chunks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  song_id uuid NOT NULL REFERENCES songs(id) ON UPDATE CASCADE ON DELETE CASCADE,
  chunk_index integer NOT NULL CHECK (chunk_index >= 0),
  byte_start bigint NOT NULL CHECK (byte_start >= 0),
  byte_end bigint NOT NULL CHECK (byte_end >= byte_start),
  sha256_hex char(64) NOT NULL,
  webtorrent_info_hash text,
  ipfs_cid text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (song_id, chunk_index),
  UNIQUE (song_id, sha256_hex)
);

CREATE INDEX IF NOT EXISTS artists_name_idx ON artists (lower(name));
CREATE INDEX IF NOT EXISTS albums_artist_title_idx ON albums (artist_id, lower(title));
CREATE INDEX IF NOT EXISTS songs_album_idx ON songs (album_id);
CREATE INDEX IF NOT EXISTS songs_primary_artist_idx ON songs (primary_artist_id);
CREATE INDEX IF NOT EXISTS p2p_chunks_song_idx ON p2p_audio_chunks (song_id, chunk_index);

COMMIT;
