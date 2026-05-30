class P2pCacheStrategy {
  const P2pCacheStrategy({
    this.chunkBytes = 512 * 1024,
    this.wifiOnlySeeding = true,
    this.maxDiskCacheBytes = 4 * 1024 * 1024 * 1024,
  });

  final int chunkBytes;
  final bool wifiOnlySeeding;
  final int maxDiskCacheBytes;

  Uri trackerAnnounce(Uri apiBase, String songId) => apiBase.replace(path: '/api/p2p/$songId/announce');
}
