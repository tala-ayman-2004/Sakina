import 'package:flutter/material.dart';
import 'package:sakina/services/API.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyMosquesPage extends StatefulWidget {
  const NearbyMosquesPage({super.key});

  @override
  State<NearbyMosquesPage> createState() => _NearbyMosquesPageState();
}

class _NearbyMosquesPageState extends State<NearbyMosquesPage> {
  late Future<List<Mosque>> _mosquesFuture;

  @override
  void initState() {
    super.initState();
    _mosquesFuture = API().fetchNearbyMosques();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        elevation: 0,
        title: const Text(
          'Nearby Mosques',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Mosque>>(
        future: _mosquesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
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

          final mosques = snapshot.data!;

          if (mosques.isEmpty) {
            return const Center(
              child: Text(
                'No mosques found nearby',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            itemCount: mosques.length,
            separatorBuilder: (_, __) => const Divider(
              height: 12,
              color: Colors.white12,
            ),
            itemBuilder: (context, index) {
              return _MosqueTile(mosques[index]);
            },
          );
        },
      ),
    );
  }
}


class _MosqueTile extends StatelessWidget {
  final Mosque m;

  const _MosqueTile(this.m);

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      // Mosque name
      title: Text(
        m.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Address + distance
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.address.isEmpty ? 'Address unavailable' : m.address,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDistance(m.distance),
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),

      // Navigation button ONLY
      trailing: IconButton(
        icon: const Icon(
          Icons.navigation,
          color: Colors.white70,
        ),
        onPressed: () async {
          final uri = Uri.parse(m.mapsLink);
          if (await canLaunchUrl(uri)) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
