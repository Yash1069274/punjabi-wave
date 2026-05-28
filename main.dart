import 'package:flutter/material.dart';

void main() => runApp(const PunjabiWaveApp());

class PunjabiWaveApp extends StatelessWidget {
  const PunjabiWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        primaryColor: const Color(0xFF0EA5E9),
      ),
      home: const RealMusicHomeScreen(),
    );
  }
}

class RealMusicHomeScreen extends StatelessWidget {
  const RealMusicHomeScreen({super.key});

  final List<Map<String, String>> realPunjabiTracks = const [
    {
      "title": "G.O.A.T.",
      "artist": "Diljit Dosanjh",
      "image": "https://unsplash.com"
    },
    {
      "title": "Softly",
      "artist": "Karan Aujla",
      "image": "https://unsplash.com"
    },
    {
      "title": "The Last Ride",
      "artist": "Sidhu Moose Wala",
      "image": "https://unsplash.com"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('ਪੰਜਾਬੀ Wave AI', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: realPunjabiTracks.length,
        itemBuilder: (context, index) {
          final track = realPunjabiTracks[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  track["image"]!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E293B),
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.music_note, color: Color(0xFF0EA5E9)),
                  ),
                ),
              ),
              title: Text(track["title"]!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              subtitle: Text(track["artist"]!, style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.play_arrow, color: Color(0xFF0EA5E9)),
            ),
          );
        },
      ),
    );
  }
}
