import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sakina/services/API.dart';
import 'package:sakina/page.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      return Scaffold(
        backgroundColor: const Color(0xFF2B2D30),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2B2D30),
          title: const Text('Bookmarks'),
        ),
        body: const Center(
          child: Text(
            'Create an account to save bookmarks',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        title: const Text(
          'Bookmarked Ayahs',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bookmarks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF229B91)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No bookmarks yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index];

              return _BookmarkCard(
                surahName: data['surahName'],
                surahNumber: data['surahNumber'],
                ayahNumber: data['ayahNumber'],
                ayahText: data['ayahText'],
                translation: data['translation'],
                onTap: () async {
                  final surah = await API().fetchSurah(data['surahNumber']);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          QuranPage(surah, initialAyah: data['ayahNumber']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final String translation;
  final VoidCallback onTap;

  const _BookmarkCard({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.translation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$surahName • Ayah $ayahNumber',
              style: const TextStyle(
                color: Color(0xFF229B91),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ayahText,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              translation,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
