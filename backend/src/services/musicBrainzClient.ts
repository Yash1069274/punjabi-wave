import { fetch } from 'undici';
import { musicBrainzUserAgent } from '../config/env.js';
import { SerialRateLimiter } from '../utils/rateLimiter.js';

const limiter = new SerialRateLimiter(1100);
const BASE_URL = 'https://musicbrainz.org/ws/2';

type QueryParams = Record<string, string | number | boolean | undefined>;

async function getJson<T>(path: string, params: QueryParams): Promise<T> {
  const url = new URL(`${BASE_URL}${path}`);
  url.searchParams.set('fmt', 'json');
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined) url.searchParams.set(key, String(value));
  }

  return limiter.schedule(async () => {
    const response = await fetch(url, {
      headers: {
        'User-Agent': musicBrainzUserAgent,
        Accept: 'application/json'
      }
    });
    if (!response.ok) {
      throw new Error(`MusicBrainz ${response.status} for ${url.pathname}: ${await response.text()}`);
    }
    return (await response.json()) as T;
  });
}

function escapeLucene(value: string): string {
  return value.replace(/([+\-&|!(){}[\]^"~*?:\\/])/g, '\\$1');
}

export type MusicBrainzRecordingSearchResult = {
  id: string;
  title: string;
  score?: number;
  length?: number;
  'artist-credit'?: Array<{ name: string; artist?: { id: string; name: string; 'sort-name'?: string; disambiguation?: string } }>;
  releases?: Array<{
    id: string;
    title: string;
    date?: string;
    status?: string;
    'release-group'?: { id: string; type?: string; 'primary-type'?: string };
    'artist-credit'?: Array<{ artist?: { id: string; name: string } }>;
    media?: Array<{ position?: number; tracks?: Array<{ id: string; title: string; number?: string; position?: number }> }>;
  }>;
};

type SearchResponse = { recordings: MusicBrainzRecordingSearchResult[] };

export async function searchRecording(input: { title: string; artist?: string; album?: string; limit?: number }) {
  const clauses = [`recording:"${escapeLucene(input.title)}"`];
  if (input.artist) clauses.push(`artist:"${escapeLucene(input.artist)}"`);
  if (input.album) clauses.push(`release:"${escapeLucene(input.album)}"`);

  return getJson<SearchResponse>('/recording', {
    query: clauses.join(' AND '),
    limit: input.limit ?? 5,
    inc: 'artists+releases+media+release-groups'
  });
}

export async function lookupArtist(mbid: string) {
  return getJson<Record<string, unknown>>(`/artist/${mbid}`, { inc: 'url-rels+aliases+tags' });
}

export async function lookupRelease(mbid: string) {
  return getJson<Record<string, unknown>>(`/release/${mbid}`, { inc: 'artists+recordings+release-groups+media' });
}
