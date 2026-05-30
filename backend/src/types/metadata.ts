export type ExtractedAudioTags = {
  title: string;
  artist?: string;
  album?: string;
  durationMs?: number;
  format?: string;
  codec?: string;
  lossless: boolean;
};

export type VerifiedArtist = {
  mbid: string;
  name: string;
  sortName?: string;
  disambiguation?: string;
  portraitUrl?: string;
};

export type VerifiedAlbum = {
  mbid: string;
  title: string;
  artistMbid: string;
  releaseDate?: string;
  coverArtUrl?: string;
};

export type VerifiedSongMetadata = {
  recordingMbid: string;
  title: string;
  confidence: number;
  artist: VerifiedArtist;
  album: VerifiedAlbum;
  artworkUrl: string;
  artworkSource: 'cover-art-archive' | 'theaudiodb-album' | 'theaudiodb-artist-fallback' | 'artist-fallback' | 'generated-placeholder';
  extracted: ExtractedAudioTags;
};
