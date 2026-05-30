import { fetch } from 'undici';
import { env } from '../config/env.js';

type ArtistResponse = { artists?: Array<Record<string, string | null>> | null };
type AlbumResponse = { album?: Array<Record<string, string | null>> | null };

const baseUrl = () => `https://www.theaudiodb.com/api/v1/json/${env.THEAUDIODB_API_KEY}`;

async function getJson<T>(path: string, params: Record<string, string | undefined>): Promise<T> {
  const url = new URL(`${baseUrl()}${path}`);
  for (const [key, value] of Object.entries(params)) {
    if (value) url.searchParams.set(key, value);
  }
  const response = await fetch(url, { headers: { Accept: 'application/json' } });
  if (!response.ok) throw new Error(`TheAudioDB ${response.status}: ${await response.text()}`);
  return (await response.json()) as T;
}

export async function findArtistPortrait(artistName: string): Promise<{ url?: string; raw: unknown }> {
  const raw = await getJson<ArtistResponse>('/search.php', { s: artistName });
  const artist = raw.artists?.[0];
  return {
    url: artist?.strArtistThumb ?? artist?.strArtistFanart ?? artist?.strArtistLogo ?? undefined,
    raw
  };
}

export async function findAlbumCover(artistName: string, albumTitle: string): Promise<{ url?: string; raw: unknown }> {
  const raw = await getJson<AlbumResponse>('/searchalbum.php', { s: artistName, a: albumTitle });
  const album = raw.album?.[0];
  return {
    url: album?.strAlbumThumb ?? undefined,
    raw
  };
}
