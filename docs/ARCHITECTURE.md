# Punjabi Wave Architecture

## Project structure

```text
punjabi-wave/
├── backend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── .env.example
│   ├── sql/
│   │   └── schema.sql
│   └── src/
│       ├── config/env.ts
│       ├── db/pool.ts
│       ├── routes/songs.ts
│       ├── server.ts
│       ├── services/
│       │   ├── artworkResolver.ts
│       │   ├── audioTagExtractor.ts
│       │   ├── metadataPipeline.ts
│       │   ├── musicBrainzClient.ts
│       │   └── theAudioDbClient.ts
│       ├── types/metadata.ts
│       ├── utils/rateLimiter.ts
│       └── workers/ingestSong.ts
├── frontend/
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   └── lib/
│       ├── main.dart
│       ├── core/theme/neon_theme.dart
│       └── features/
│           ├── equalizer/gesture_equalizer.dart
│           ├── lyrics/synced_lyrics_canvas.dart
│           ├── p2p/p2p_cache_strategy.dart
│           ├── player/neon_player_screen.dart
│           └── queue/similarity_queue.dart
├── docker-compose.yml
└── docs/ARCHITECTURE.md
```

## Self-correcting metadata pipeline

1. `audioTagExtractor.ts` reads embedded tags and detects lossless FLAC/WAV/AIFF/ALAC material.
2. `musicBrainzClient.ts` sends MusicBrainz recording searches with a compliant User-Agent and a serial rate limiter.
3. `metadataPipeline.ts` scores candidates by title, artist, duration, and MusicBrainz score. Low-confidence matches are rejected instead of saved.
4. `artworkResolver.ts` tries Cover Art Archive release artwork first, then TheAudioDB album artwork, then TheAudioDB artist portrait, and finally a deterministic generated placeholder.
5. `schema.sql` prevents artist/album/song mismatches with `songs_album_artist_fk`, a composite foreign key from each song's `(album_id, primary_artist_id)` to the album's `(id, artist_id)`.

## Anti-standard music UI

The Flutter app intentionally avoids flat list-first discovery and a standard bottom tab bar. The player centers the experience around `FluidArtOrb`, an animated pseudo-3D canvas that wraps verified album artwork or the singer portrait fallback in a neon glass sphere with spatial audio bubbles.

## Premium feature implementation plan

- **Lossless playback:** use `just_audio` with platform audio sessions and serve original FLAC/WAV objects when the device supports them. For unsupported devices, add an optional local-only transcoding proxy while keeping the canonical file lossless.
- **Gesture equalizer:** `GestureEqualizer` maps horizontal drag position to EQ band and vertical drag position to gain. Production builds should bridge these values to native Android `Equalizer`/iOS audio units.
- **Synchronized lyrics canvas:** store LRC in `lyrics.lrc_text` and drive `SyncedLyricsCanvas.activeIndex` from the audio clock.
- **AI queue mixing:** store embeddings in `acoustic_features.embedding` and query nearest neighbors in `/api/songs/:id/queue/similar`.

## Free operational model: decentralized audio delivery

The backend should be treated as metadata, auth, and tracker coordination only. Audio bytes are chunked into content-addressed pieces in `p2p_audio_chunks`.

Recommended flow:

1. During ingestion, split each song into 512 KiB chunks and store chunk SHA-256 hashes.
2. Publish chunks to IPFS, WebTorrent, or both. The server stores only the `ipfs_cid`/`webtorrent_info_hash` plus integrity hashes.
3. Flutter downloads the first chunks from any available gateway or seed to minimize startup latency.
4. Once playback begins, the app seeds cached chunks to peers when the device is charging or on Wi-Fi.
5. The backend exposes only signed manifests and a lightweight tracker endpoint; it does not proxy whole songs.
6. If no peers exist, a volunteer seedbox or free object-store quota can seed the first copy, but clients quickly take over bandwidth.

This model keeps server egress near zero while preserving exact-file verification with the stored SHA-256 chunk hashes.

## Local setup commands

```bash
# 1. Start PostgreSQL.
docker compose up -d postgres

# 2. Configure backend environment.
cp backend/.env.example backend/.env

# 3. Install backend dependencies.
cd backend && npm install

# 4. Run migrations against the local database.
DATABASE_URL=postgres://postgres:postgres@localhost:5432/punjabi_wave npm run db:migrate

# 5. Start the Node.js API.
npm run dev

# 6. In another shell, install Flutter dependencies.
cd frontend && flutter pub get

# 7. Run the Flutter app.
flutter run

# 8. Ingest a local audio file and auto-map metadata/artwork.
cd backend && npm run metadata:ingest -- /absolute/path/to/song.flac
```
