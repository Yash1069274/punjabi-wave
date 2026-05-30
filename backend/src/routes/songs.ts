import type { FastifyInstance } from 'fastify';
import { pool } from '../db/pool.js';

export async function songRoutes(app: FastifyInstance) {
  app.get('/songs', async () => {
    const { rows } = await pool.query(`
      SELECT
        s.id, s.title, s.audio_uri, s.audio_format, s.is_lossless, s.artwork_url,
        a.name AS artist_name, a.portrait_url,
        al.title AS album_title, al.cover_art_url
      FROM songs s
      JOIN artists a ON a.id = s.primary_artist_id
      JOIN albums al ON al.id = s.album_id AND al.artist_id = s.primary_artist_id
      WHERE s.verification_state = 'verified'
      ORDER BY s.created_at DESC
      LIMIT 100
    `);
    return { songs: rows };
  });

  app.get('/songs/:id/queue/similar', async (request) => {
    const { id } = request.params as { id: string };
    const { rows } = await pool.query(
      `WITH source AS (
         SELECT embedding FROM acoustic_features WHERE song_id = $1
       )
       SELECT s.id, s.title, s.artwork_url, a.name AS artist_name
       FROM acoustic_features af
       JOIN source ON af.song_id <> $1
       JOIN songs s ON s.id = af.song_id
       JOIN artists a ON a.id = s.primary_artist_id
       ORDER BY (
         SELECT SUM((af.embedding[i] - source.embedding[i]) * (af.embedding[i] - source.embedding[i]))
         FROM generate_subscripts(af.embedding, 1) i
       ) ASC NULLS LAST
       LIMIT 25`,
      [id]
    );
    return { songs: rows };
  });
}
