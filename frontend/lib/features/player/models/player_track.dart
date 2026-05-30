class PlayerTrack {
  const PlayerTrack({
    required this.id,
    required this.title,
    required this.artistName,
    required this.albumTitle,
    required this.audioUri,
    required this.artworkUrl,
    required this.artistPortraitUrl,
    required this.isLossless,
  });

  final String id;
  final String title;
  final String artistName;
  final String albumTitle;
  final String audioUri;
  final String artworkUrl;
  final String artistPortraitUrl;
  final bool isLossless;
}
