# Punjabi Wave

Punjabi Wave is a free-first mobile music streaming architecture with a Flutter neon-glassmorphic frontend and a Node.js/PostgreSQL backend.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the complete folder structure, database schema overview, metadata pipeline, UI plan, premium feature plan, P2P caching model, and local setup commands.

Core implementation files:

- Backend schema: `backend/sql/schema.sql`
- MusicBrainz metadata pipeline: `backend/src/services/metadataPipeline.ts`
- MusicBrainz client: `backend/src/services/musicBrainzClient.ts`
- TheAudioDB artwork fallback: `backend/src/services/theAudioDbClient.ts`
- Flutter neon player: `frontend/lib/features/player/neon_player_screen.dart`
