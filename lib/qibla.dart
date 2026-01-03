import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage> {
  double? _qiblaDirection;

  @override
  void initState() {
    super.initState();
    _loadQiblaDirection();
  }

  Future<void> _loadQiblaDirection() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    final bearing = calculateQiblaDirection(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (!mounted) return;

    setState(() {
      _qiblaDirection = bearing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_qiblaDirection == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2B2D30),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2D30),
        title: const Text('Qibla Compass'),
      ),
      body: Center(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.heading == null) {
              return const Text(
                'Compass not available',
                style: TextStyle(color: Colors.white),
              );
            }

            final heading = snapshot.data!.heading!;
            final rotation = (_qiblaDirection! - heading) * pi / 180;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: rotation,
                      child:  Icon(
                        Icons.navigation,
                        size: 120,
                        color: Color(0xFF229B91),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Face this direction',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

double calculateQiblaDirection({
  required double latitude,
  required double longitude,
}) {
  const kaabaLat = 21.4225;
  const kaabaLng = 39.8262;

  final lat1 = latitude * pi / 180;
  final lat2 = kaabaLat * pi / 180;
  final dLon = (kaabaLng - longitude) * pi / 180;

  final y = sin(dLon);
  final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon);

  final bearing = atan2(y, x) * 180 / pi;

  return (bearing + 360) % 360;
}
