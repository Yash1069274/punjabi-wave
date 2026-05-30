import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(8080),
  DATABASE_URL: z.string().url(),
  PUBLIC_API_BASE_URL: z.string().url().default('http://localhost:8080'),
  MUSICBRAINZ_APP_NAME: z.string().default('PunjabiWave'),
  MUSICBRAINZ_APP_VERSION: z.string().default('0.1.0'),
  MUSICBRAINZ_CONTACT_EMAIL: z.string().email(),
  THEAUDIODB_API_KEY: z.string().default('2')
});

export const env = envSchema.parse(process.env);

export const musicBrainzUserAgent = `${env.MUSICBRAINZ_APP_NAME}/${env.MUSICBRAINZ_APP_VERSION} (${env.MUSICBRAINZ_CONTACT_EMAIL})`;
