import 'package:flutter/material.dart';
import 'package:sakina/qibla.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:sakina/app_footer.dart';
import 'package:sakina/services/API.dart';
import 'package:sakina/Ramadan.dart';
import 'package:sakina/quran.dart';
import 'package:sakina/mosques.dart';
import 'package:sakina/prayerPage.dart';
import 'package:sakina/Athkar.dart';
import 'package:sakina/Ask_Ai.dart';
import 'package:sakina/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

//everything thats left
// add the notification system

// clean the code
//fix ui in some places

// possible: add all the sections's pages , like the ummah page, videos page, features page etc.
// possible: implement the social features of ummah page and add likes and comments, and image uploads and connect to firebase
// add something to the memorize section
class _HomeState extends State<Home> {
  late Future<Map<String, String>> times;
  late Future<String> city;

  @override
  void initState() {
    super.initState();
    times = API().getTodayPrayerTimes();
    city = API().getCurrentCity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        title: Image.asset("assets/images/Title.png", height: 60),
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.notifications_active,
                size: 40,
                color: Color(0xFF229B91),
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFF2B2D30),
              padding: const EdgeInsets.only(left: 16, bottom: 20),
              alignment: Alignment.bottomLeft,
              child: const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton(
                onPressed: () {},
                child: const Text('Mark all as read'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: 1, 
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrayerPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),

      backgroundColor: const Color(0xFF2B2D30),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _prayerCard(),
            const SizedBox(height: 20),
            _featuresSection(),
            const SizedBox(height: 20),
            _AssetVideoCard(),
            const SizedBox(height: 20),
            _videosSection(),
            const SizedBox(height: 20),
            _ummahSection(),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrayerPage()),
                  );
                });
              },
              child: const Text(
                "Load More",
                style: TextStyle(color: Color(0xFF229B91)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRAYER TIMES CARD UI

  Widget _prayerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<Map<String, String>>(
        future: times,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Text(
              'Failed to load prayer times',
              style: TextStyle(color: Colors.white),
            );
          }

          final t = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF229B91),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: city,
                          builder: (context, citySnapshot) {
                            if (citySnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                'Locating…',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              );
                            }

                            if (citySnapshot.hasError ||
                                !citySnapshot.hasData) {
                              return const Text(
                                'Unknown location',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              );
                            }

                            return Text(
                              citySnapshot.data!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 6),
                        Text(
                          '${t["Year"]} ${t["Month"]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.wb_twilight,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Prayer Times
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PrayerItem(
                    'Fajr',
                    Icons.wb_twilight,
                    t['Fajr']!,
                    active: true,
                  ),
                  _PrayerItem('Sunrise', Icons.wb_sunny, t['Sunrise']!),
                  _PrayerItem('Dhuhr', Icons.wb_sunny, t['Dhuhr']!),
                  _PrayerItem('Asr', Icons.wb_cloudy, t['Asr']!),
                  _PrayerItem('Maghrib', Icons.nights_stay, t['Maghrib']!),
                  _PrayerItem('Isha', Icons.nightlight, t['Isha']!),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _featuresSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Features',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FeatureItem(
                  icon: Icons.explore,
                  label: 'Qibla',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QiblaCompassPage(),
                      ),
                    );
                  },
                ),
                _FeatureItem(
                  icon: Icons.pan_tool,
                  label: 'Athkar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AthkarPage()),
                    );
                  },
                ), // change this one
                _FeatureItem(
                  icon: Icons.menu_book,
                  label: 'Quran',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuranHomePage(),
                      ),
                    );
                  },
                ),
                _FeatureItem(
                  icon: Icons.mosque,
                  label: 'Mosques',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NearbyMosquesPage(),
                      ),
                    );
                  },
                ),
                _FeatureItem(
                  icon: Icons.smart_toy,
                  label: 'Ask Ai',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NurChatPage(),
                      ),
                    );
                  },
                ),
                _FeatureItem(
                  icon: Icons.nightlight_round,
                  label: 'Ramadan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Ramadan()),
                    );
                  },
                ),
                _FeatureItem(
                  icon: Icons.restaurant,
                  label: 'Halal Places',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Islamic Videos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(color: Color(0xFF229B91)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 210,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _YoutubeVideoCard(
                  videoId: 'aSmzRxLSuks',
                  title: 'رحلة الخلود 1',
                  channel: 'anas-action',
                ),
                _YoutubeVideoCard(
                  videoId: 'djabCVqb1ug',
                  title: 'رحلة الخلود 2',
                  channel: 'anas-action',
                ),
                _YoutubeVideoCard(
                  videoId: '6uqy5gpWnIA',
                  title: 'رحلة الخلود 3',
                  channel: 'anas-action',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ummahSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ummah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'More',
                  style: TextStyle(color: Color(0xFF229B91)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 320,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: const [
                _UmmahPostCard(
                  username: 'Faith Talks',
                  caption:
                      'May Allah give you and your family peace and ease 🤍',
                  likes: 246,
                  location: 'Makkah',
                ),
                SizedBox(height: 16),
                _UmmahPostCard(
                  username: 'Bilal Uthman',
                  caption: 'Beautiful Madinah. Prophet’s Masjid ﷺ',
                  likes: 314,
                  location: 'Madinah',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SINGLE PRAYER ITEM
class _PrayerItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final String time;
  final bool active;

  const _PrayerItem(this.name, this.icon, this.time, {this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF229B91) : Colors.white70;

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(name, style: TextStyle(color: color, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// single feature itme
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(icon, color: const Color(0xFF229B91), size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// single youtube video card

class _YoutubeVideoCard extends StatelessWidget {
  final String videoId;
  final String title;
  final String channel;
  final bool isLive;

  const _YoutubeVideoCard({
    required this.videoId,
    required this.title,
    required this.channel,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                if (isLive)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Text
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    channel,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
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

//mecca video card
class _AssetVideoCard extends StatefulWidget {
  const _AssetVideoCard();

  @override
  State<_AssetVideoCard> createState() => _AssetVideoCardState();
}

class _AssetVideoCardState extends State<_AssetVideoCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/mecca_video.mp4')
      ..setLooping(true)
      ..setVolume(0) // REQUIRED for autoplay on iOS
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const SizedBox(
                    height: 130,
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
        ],
      ),
    );
  }
}

class _UmmahPostCard extends StatelessWidget {
  final String username;
  final String caption;
  final int likes;
  final String? location;

  const _UmmahPostCard({
    required this.username,
    required this.caption,
    required this.likes,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF229B91),
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                if (location != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    location!,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 8),

                Text(
                  caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Colors.white60,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      likes.toString(),
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
