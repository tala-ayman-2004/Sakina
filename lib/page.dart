import 'package:flutter/material.dart';
import 'package:sakina/services/API.dart';
import 'package:just_audio/just_audio.dart';

class QuranPage extends StatefulWidget {
  final Surah surah;

  const QuranPage(this.surah, {super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late Future<List<Ayah>> _ayahsFuture;

  // Audio players
  late AudioPlayer _surahPlayer;
  late AudioPlayer _ayahPlayer;

  bool _isSurahLoaded = false;
  int? _playingAyah;

  @override
  void initState() {
    super.initState();

    _ayahsFuture = API().fetchSurahAyahs(widget.surah.number);

    _surahPlayer = AudioPlayer();
    _ayahPlayer = AudioPlayer();

    // Reset ayah state when finished
    _ayahPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() => _playingAyah = null);
      }
    });
  }

  @override
  void dispose() {
    _surahPlayer.dispose();
    _ayahPlayer.dispose();
    super.dispose();
  }

  // ▶ Play / Resume full surah
  Future<void> _playSurah() async {
    try {
      if (_isSurahLoaded) {
        _surahPlayer.play();
        return;
      }

      final url = await API().fetchAudioUrl(widget.surah.number);
      await _surahPlayer.setUrl(url);
      await _surahPlayer.play();

      _isSurahLoaded = true;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play surah audio')),
      );
    }
  }

  // ▶ Play single ayah
  Future<void> _playAyah(int ayahNumber) async {
    try {
      // Toggle pause if same ayah
      if (_playingAyah == ayahNumber && _ayahPlayer.playing) {
        await _ayahPlayer.pause();
        setState(() => _playingAyah = null);
        return;
      }

      final url =
          await API().fetchverse(widget.surah.number, ayahNumber);

      await _ayahPlayer.setUrl(url);
      await _ayahPlayer.play();

      setState(() => _playingAyah = ayahNumber);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play ayah audio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        elevation: 0,
        title: const Text(
          'MyQuran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _surahHeader(),
            const SizedBox(height: 16),
            _bismillah(),
            const SizedBox(height: 16),
            Expanded(child: _ayahList()),
          ],
        ),
      ),
    );
  }

  // 🔹 HEADER (unchanged UI)
  Widget _surahHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5EC4B8), Color(0xFF47A89E)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: Colors.white70, size: 30),
          const SizedBox(height: 8),
          Text(
            widget.surah.nameEn,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.surah.nameAr,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            widget.surah.info,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ▶ Surah play / pause button
  Widget _bismillah() {
    return Column(
      children: [
        const Text(
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.teal,
          ),
        ),
        StreamBuilder<PlayerState>(
          stream: _surahPlayer.playerStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final processing = state?.processingState;
            final playing = state?.playing ?? false;

            if (processing == ProcessingState.loading ||
                processing == ProcessingState.buffering) {
              return const CircularProgressIndicator(color: Colors.white);
            }

            return IconButton(
              icon: Icon(
                playing ? Icons.pause_circle : Icons.play_circle,
                color: Colors.white,
                size: 36,
              ),
              onPressed:
                  playing ? _surahPlayer.pause : _playSurah,
            );
          },
        ),
      ],
    );
  }

  // 📜 AYAH LIST
  Widget _ayahList() {
    return FutureBuilder<List<Ayah>>(
      future: _ayahsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF229B91)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final ayahs = snapshot.data!;

        return ListView.separated(
          itemCount: ayahs.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final ayah = ayahs[index];
            return _AyahTile(
              ayah: ayah,
              isPlaying: _playingAyah == ayah.number,
              onPlay: () => _playAyah(ayah.number),
            );
          },
        );
      },
    );
  }
}

// 🔹 AYAH TILE (UI unchanged)
class _AyahTile extends StatelessWidget {
  final Ayah ayah;
  final bool isPlaying;
  final VoidCallback onPlay;

  const _AyahTile({
    required this.ayah,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              child: Text(
                ayah.number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.white,
                size: 24,
              ),
              onPressed: onPlay,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.share, size: 20, color: Colors.teal),
            const SizedBox(width: 12),
            const Icon(Icons.bookmark_border, size: 20, color: Colors.teal),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          ayah.ar,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ayah.eng,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}
