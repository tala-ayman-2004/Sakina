import 'package:flutter/material.dart';
import 'package:sakina/page.dart';
import 'package:sakina/services/API.dart';

class QuranChaptersPage extends StatefulWidget {
  const QuranChaptersPage({super.key});

  @override
  State<QuranChaptersPage> createState() => _QuranChaptersPageState();
}

class _QuranChaptersPageState extends State<QuranChaptersPage> {
  late Future<List<Surah>> _surahsFuture;

  @override
  void initState() {
    super.initState();
    _surahsFuture = API().fetchQuranList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF229B91),
        elevation: 0,
        title: const Text(
          'MyQuran',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 16),
            Expanded(child: _surahList()),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _surahList() {
    return FutureBuilder<List<Surah>>(
      future: _surahsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF229B91)),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load surahs',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final surahs = snapshot.data!;

        return ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];

            return _SurahTile(
              number: surah.number,
              nameEn: surah.nameEn,
              nameAr: surah.nameAr,
              info: surah.info, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranPage(surah),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
class _SurahTile extends StatelessWidget {
  final int number;
  final String nameEn;
  final String nameAr;
  final String info;
  final VoidCallback onTap;

  const _SurahTile({
    required this.number,
    required this.nameEn,
    required this.nameAr,
    required this.info,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF229B91),
        child: Text(
          number.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        nameEn,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameAr,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            info,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}