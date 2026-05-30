import { pool } from '../db/pool.js';
import { persistVerifiedMetadata, verifySongMetadataFromFile } from '../services/metadataPipeline.js';

const filePath = process.argv[2];
if (!filePath) {
  console.error('Usage: npm run metadata:ingest -- /absolute/path/to/song.flac');
  process.exit(1);
}

const metadata = await verifySongMetadataFromFile(filePath);
const songId = await persistVerifiedMetadata(pool, filePath, metadata);
console.log(JSON.stringify({ songId, metadata }, null, 2));
await pool.end();
