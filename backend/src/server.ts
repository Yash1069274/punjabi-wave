import Fastify from 'fastify';
import cors from '@fastify/cors';
import multipart from '@fastify/multipart';
import { env } from './config/env.js';
import { songRoutes } from './routes/songs.js';

const app = Fastify({ logger: { transport: env.NODE_ENV === 'development' ? { target: 'pino-pretty' } : undefined } });

await app.register(cors, { origin: true });
await app.register(multipart, { limits: { fileSize: 1024 * 1024 * 512 } });
await app.register(songRoutes, { prefix: '/api' });

app.get('/health', async () => ({ ok: true }));

await app.listen({ port: env.PORT, host: '0.0.0.0' });
