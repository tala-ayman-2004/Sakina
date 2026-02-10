import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/API.dart';
import 'app_footer.dart';
import 'profile.dart';
import 'home.dart';

enum PrayerPhase { fajr, dhuhr, asr, maghrib, isha }

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}


List<DateTime> last7Days() {
  final today = DateTime.now();
  return List.generate(7, (i) {
    return DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: 6 - i));
  });
}

String dayId(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String dayLabel(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}


class _PrayerPageState extends State<PrayerPage> {
  PrayerPhase currentPhase = PrayerPhase.fajr;
  bool prayDisabled = false;

  @override
  void initState() {
    super.initState();
    _initCurrentPrayerPhase();
  }


  Future<void> _initCurrentPrayerPhase() async {
    final api = API();
    final times = await api.getTodayPrayerTimes();
    final now = DateTime.now();

    DateTime parse(String t) {
      final p = t.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(p[0]),
        int.parse(p[1]),
      );
    }

    final fajr = parse(times['Fajr']!);
    final dhuhr = parse(times['Dhuhr']!);
    final asr = parse(times['Asr']!);
    final maghrib = parse(times['Maghrib']!);
    final isha = parse(times['Isha']!);

    PrayerPhase phase;

    if (now.isBefore(fajr)) {
      phase = PrayerPhase.isha;
    } else if (now.isBefore(dhuhr)) {
      phase = PrayerPhase.fajr;
    } else if (now.isBefore(asr)) {
      phase = PrayerPhase.dhuhr;
    } else if (now.isBefore(maghrib)) {
      phase = PrayerPhase.asr;
    } else if (now.isBefore(isha)) {
      phase = PrayerPhase.maghrib;
    } else {
      phase = PrayerPhase.isha;
    }

    setState(() {
      currentPhase = phase;
      prayDisabled = false;
    });
  }


  Future<void> markPrayerAsPrayed(PrayerPhase phase) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('prayer_logs')
        .doc(dayId(DateTime.now()));

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.exists ? snap.data()! : {};

      if (data[phase.name] == true) return;

      tx.set(docRef, {
        phase.name: true,
        'completedCount': (data['completedCount'] ?? 0) + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }


  Future<void> _onPrayNowPressed() async {
    if (prayDisabled) return;

    await markPrayerAsPrayed(currentPhase);

    setState(() {
      prayDisabled = true;
      currentPhase = PrayerPhase
          .values[(currentPhase.index + 1) % PrayerPhase.values.length];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2B2D30),
        elevation: 0,
        title: const Text(
          'Prayer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B2D30), Color(0xFF229B91)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              children: [
                const SizedBox(height: 24),
                SizedBox(
                  height: 340,
                  child: Center(
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final center = constraints.maxWidth / 2;
                          const radius = 165.0;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: center - 110,
                                top: center - 110,
                                child: Moon(phase: currentPhase),
                              ),
                              ...PrayerPhase.values.map((phase) {
                                final index = phase.index;
                                final angle = (2 * pi / 5) * index - pi / 2;
                                final x = center + radius * cos(angle);
                                final y = center + radius * sin(angle);

                                return Positioned(
                                  left: x - 12,
                                  top: y - 12,
                                  child: _PrayerOrbitItem(
                                    label:
                                        phase.name[0].toUpperCase() +
                                        phase.name.substring(1),
                                    active: currentPhase == phase,
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: prayDisabled
                          ? Colors.grey
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: prayDisabled ? null : _onPrayNowPressed,
                    child: const Text(
                      'Pray Now',
                      style: TextStyle(
                        color: Color(0xFF3B355E),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const WeeklyPrayerProgress(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Moon extends StatelessWidget {
  final PrayerPhase phase;

  const Moon({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    final theme = moonThemeByPrayer[phase]!;

    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: theme.gradient),
        boxShadow: [
          BoxShadow(
            color: theme.glow.withOpacity(0.8),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _PrayerOrbitItem extends StatelessWidget {
  final String label;
  final bool active;

  const _PrayerOrbitItem({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: active ? 14 : 10,
          height: active ? 14 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.white : Colors.white60,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class MoonColors {
  final List<Color> gradient;
  final Color glow;

  const MoonColors(this.gradient, this.glow);
}

const Map<PrayerPhase, MoonColors> moonThemeByPrayer = {
  PrayerPhase.fajr: MoonColors([
    Color(0xFFE6F7FF),
    Color(0xFF9AD9FF),
    Color(0xFF4DA8DA),
  ], Color(0xFF9AD9FF)),
  PrayerPhase.dhuhr: MoonColors([
    Color(0xFFFFF1C1),
    Color(0xFFFFD27D),
    Color(0xFFFFB703),
  ], Color(0xFFFFD27D)),
  PrayerPhase.asr: MoonColors([
    Color(0xFFFFE0B2),
    Color(0xFFFFB74D),
    Color(0xFFF57C00),
  ], Color(0xFFFFB74D)),
  PrayerPhase.maghrib: MoonColors(
    [
      Color(0xFFFFC46B), 
      Color(0xFFFF8F1F),
      Color(0xFFB45309), 
    ],
    Color(0xFFFF8F1F), 
  ),

  PrayerPhase.isha: MoonColors([
    Color(0xFFF6F4FF),
    Color(0xFFD8D2FF),
    Color(0xFFB5ACFF),
  ], Color(0xFFB5ACFF)),
};

class PrayerProgressRing extends StatelessWidget {
  final int completed;
  final bool isToday;

  const PrayerProgressRing({
    super.key,
    required this.completed,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = completed / 5;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(
              completed == 5
                  ? const Color(0xFF22C55E) // green (complete)
                  : const Color(0xFF229B91), // app teal
            ),
          ),
        ),
        if (isToday)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class WeeklyPrayerProgress extends StatelessWidget {
  const WeeklyPrayerProgress({super.key});

  Stream<QuerySnapshot> _weekStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('prayer_logs')
        .orderBy(FieldPath.documentId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final days = last7Days();
    final todayId = dayId(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          StreamBuilder<QuerySnapshot>(
            stream: _weekStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final Map<String, Map<String, dynamic>> dataByDay = {
                for (var doc in snapshot.data!.docs)
                  doc.id: doc.data() as Map<String, dynamic>,
              };

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.map((date) {
                  final id = dayId(date);
                  final data = dataByDay[id];

                  final completed = data != null
                      ? (data['completedCount'] ?? 0)
                      : 0;

                  final isToday = id == todayId;

                  return Column(
                    children: [
                      Text(
                        dayLabel(date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white60,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      PrayerProgressRing(
                        completed: completed,
                        isToday: isToday,
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
