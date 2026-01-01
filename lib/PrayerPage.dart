import 'dart:math';
import 'package:flutter/material.dart';

enum PrayerPhase {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  final PrayerPhase currentPhase = PrayerPhase.isha;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Prayer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B2D30),
                Color(0xFF229B91),
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // 🔹 TOP INFO CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    Text(
                      '22:13',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Next prayer • Fajr in 4h 12m',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 🌙 MOON + PRAYERS (FIXED & SPACED)
              SizedBox(
                height: 340,
                width: double.infinity,
                child: Center(
                  child: SizedBox(
                    width: 320,
                    height: 320,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final center = constraints.maxWidth / 2;
                        const radius = 165.0; // 👈 prayers further out

                        final prayers = [
                          'Fajr',
                          'Dhuhr',
                          'Asr',
                          'Maghrib',
                          'Isha',
                        ];

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 🌙 Moon (center)
                            Positioned(
                              left: center - 110,
                              top: center - 110,
                              child: const Moon(),
                            ),

                            // 🕋 Prayers around moon
                            ...List.generate(prayers.length, (index) {
                              final angle =
                                  (2 * pi / prayers.length) * index -
                                      pi / 2;

                              final x = center + radius * cos(angle);
                              final y = center + radius * sin(angle);

                              return Positioned(
                                left: x - 12,
                                top: y - 12,
                                child: _PrayerOrbitItem(
                                  label: prayers[index],
                                  active: prayers[index] == 'Isha',
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

              const Spacer(),

              // 🔘 Pray Now Button (NO container behind)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🌙 Moon widget
class Moon extends StatelessWidget {
  const Moon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFFF6F4FF),
            Color(0xFFD8D2FF),
            Color(0xFFB5ACFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB5ACFF),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

// 🔘 Prayer dot around moon
class _PrayerOrbitItem extends StatelessWidget {
  final String label;
  final bool active;

  const _PrayerOrbitItem({
    required this.label,
    required this.active,
  });

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
