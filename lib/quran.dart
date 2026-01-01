import 'package:flutter/material.dart';
import 'chapters.dart';
import 'Tajweed.dart';

class QuranHomePage extends StatelessWidget {
  const QuranHomePage({super.key});

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Quran Illustration
            Image.asset(
              'assets/images/quran_icon.png',
              height: 120,
            ),

            const SizedBox(height: 20),

            // Last Read Card
            _LastReadCard(
              onTap: () {
                // Navigate to Last Read Page
              },
            ),

            const SizedBox(height: 20),

            // Feature Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _FeatureCard(
                    title: 'Quran',
                    icon: Icons.menu_book,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6BC7C2), Color(0xFF4CA6A1)],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuranChaptersPage(),
                        ),
                      );
                    },
                  ),
                  _FeatureCard(
                    title: 'Memorize',
                    icon: Icons.nightlight_round,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF38EB0), Color(0xFFEA6A9E)],
                    ),
                    onTap: () {
                      // Navigate to Memorize Page
                    },
                  ),
                  _FeatureCard(
                    title: 'Tajwid List',
                    icon: Icons.school,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB08EEA), Color(0xFF8F6ED5)],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuranRulesPage(),
                        ),
                      );
                    },
                  ),
                  _FeatureCard(
                    title: 'Bookmarks',
                    icon: Icons.bookmark,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7FAAF0), Color(0xFF5D87D8)],
                    ),
                    onTap: () {
                      // Navigate to Bookmarks Page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _LastReadCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LastReadCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5EC4B8), Color(0xFF47A89E)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Last Read',
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 4),
                Text(
                  'Ar-Rahman',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Verse No. 1',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
            Icon(Icons.mosque, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }
}
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
