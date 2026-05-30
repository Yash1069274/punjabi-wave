import { parseFile } from 'music-metadata';
import path from 'node:path';
import type { ExtractedAudioTags } from '../types/metadata.js';

const LOSSLESS_CODECS = new Set(['FLAC', 'PCM', 'ALAC', 'APE', 'WAVPACK']);
const LOSSLESS_EXTENSIONS = new Set(['.flac', '.wav', '.aiff', '.aif', '.alac']);

function titleFromFilename(filePath: string): string {
  return path.basename(filePath, path.extname(filePath)).replace(/[_-]+/g, ' ').replace(/\s+/g, ' ').trim();
}

export async function extractAudioTags(filePath: string): Promise<ExtractedAudioTags> {
  const metadata = await parseFile(filePath, { duration: true });
  const extension = path.extname(filePath).toLowerCase();
  const codec = metadata.format.codec?.toUpperCase();
  const lossless = Boolean(
    metadata.format.lossless ||
      (codec && LOSSLESS_CODECS.has(codec)) ||
      LOSSLESS_EXTENSIONS.has(extension)
  );

  return {
    title: metadata.common.title?.trim() || titleFromFilename(filePath),
    artist: metadata.common.artist?.trim() || metadata.common.artists?.[0]?.trim(),
    album: metadata.common.album?.trim(),
    durationMs: metadata.format.duration ? Math.round(metadata.format.duration * 1000) : undefined,
    format: metadata.format.container ?? extension.replace('.', ''),
    codec,
    lossless
  };
}
