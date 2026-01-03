import 'package:flutter/material.dart';
import 'package:sakina/services/API.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuranPage extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;

  const QuranPage(this.surah, {this.initialAyah, super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late Future<List<Ayah>> _ayahsFuture;
  late AudioPlayer _surahPlayer;
  late AudioPlayer _ayahPlayer;

  bool _isSurahLoaded = false;
  int? _playingAyah;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _ayahsFuture = API().fetchSurahAyahs(widget.surah.number);
    _surahPlayer = AudioPlayer();
    _ayahPlayer = AudioPlayer();

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
    _scrollController.dispose();
  }


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
      _toast('Failed to play surah audio');
    }
  }

  Future<void> _playAyah(int ayahNumber) async {
    try {
      if (_playingAyah == ayahNumber && _ayahPlayer.playing) {
        await _ayahPlayer.pause();
        setState(() => _playingAyah = null);
        return;
      }

      setState(() => _playingAyah = ayahNumber);

      final url = await API().fetchverse(widget.surah.number, ayahNumber);

      await _ayahPlayer.setUrl(url);
      await _ayahPlayer.play();
    } catch (_) {
      setState(() => _playingAyah = null);
      _toast('Failed to play ayah audio');
    }
  }


  Future<void> toggleBookmark(Ayah ayah) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      _toast('Create an account to save bookmarks');
      return;
    }

    final docId = '${widget.surah.number}_${ayah.number}';

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId);

    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'surahNumber': widget.surah.number,
        'surahName': widget.surah.nameAr,
        'ayahNumber': ayah.number,
        'ayahText': ayah.ar,
        'translation': ayah.eng,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isBookmarked(Ayah ayah) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      return Stream<bool>.value(false);
    }

    final docId = '${widget.surah.number}_${ayah.number}';

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
            final playing = snapshot.data?.playing ?? false;
            return IconButton(
              icon: Icon(
                playing ? Icons.pause_circle : Icons.play_circle,
                color: Colors.white,
                size: 36,
              ),
              onPressed: playing ? _surahPlayer.pause : _playSurah,
            );
          },
        ),
      ],
    );
  }

  Widget _ayahList() {
    return FutureBuilder<List<Ayah>>(
      future: _ayahsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF229B91)),
          );
        }

        final ayahs = snapshot.data!;
        if (widget.initialAyah != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final index = ayahs.indexWhere(
              (a) => a.number == widget.initialAyah,
            );
            if (index != -1 && _scrollController.hasClients) {
              _scrollController.animateTo(
                index * 140.0, 
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
        }

        return ListView.separated(
          controller: _scrollController,
          itemCount: ayahs.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (context, index) {
            final ayah = ayahs[index];

            return StreamBuilder<bool>(
              stream: isBookmarked(ayah),
              builder: (context, snap) {
                final bookmarked = snap.data ?? false;

                return _AyahTile(
                  ayah: ayah,
                  isPlaying: _playingAyah == ayah.number,
                  bookmarked: bookmarked,
                  onPlay: () => _playAyah(ayah.number),
                  onBookmark: () => toggleBookmark(ayah),
                );
              },
            );
          },
        );
      },
    );
  }
}


class _AyahTile extends StatelessWidget {
  final Ayah ayah;
  final bool isPlaying;
  final bool bookmarked;
  final VoidCallback onPlay;
  final VoidCallback onBookmark;

  const _AyahTile({
    required this.ayah,
    required this.isPlaying,
    required this.bookmarked,
    required this.onPlay,
    required this.onBookmark,
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
             Spacer(),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.white,
                size: 24,
              ),
              onPressed: onPlay,
            ),
             SizedBox(width: 12),
             Icon(Icons.share, size: 20, color: Colors.teal),
             SizedBox(width: 12),
            IconButton(
              icon: Icon(
                bookmarked ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
                color: Colors.teal,
              ),
              onPressed: onBookmark,
            ),
          ],
        ),
         SizedBox(height: 12),
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
