import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class API {
  // these three are here because overpass breaks a lot so we need it to try multiple servers and cache results to reduce load times
  static final Map<String, _CacheEntry<List<Mosque>>> _mosqueCache = {};
  static final Duration _cacheTTL = const Duration(minutes: 10);  
  static const List<String> _overpassServers = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.fr/api/interpreter',
  ];

  Future<Position> loc() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Position(
        latitude: 31.9684608,
        longitude: 35.8842368,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
        isMocked: true,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Map<String, String>> getTodayPrayerTimes() async {
    final position = await loc();

    final today = DateTime.now();
    final date = '${today.day}-${today.month}-${today.year}';

    final url = Uri.https('api.aladhan.com', '/v1/timings/$date', {
      'latitude': position.latitude.toString(),
      'longitude': position.longitude.toString(),
      'method': '4',
    });

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load prayer times');
    }

    final data = jsonDecode(response.body);
    final timings = data['data']['timings'];
    final hijri = data['data']['date']['hijri'];

    return {
      'Month': hijri['month']['en'],
      'Year': hijri['year'],
      'Fajr': timings['Fajr'],
      'Sunrise': timings['Sunrise'],
      'Dhuhr': timings['Dhuhr'],
      'Asr': timings['Asr'],
      'Maghrib': timings['Maghrib'],
      'Isha': timings['Isha'],
    };
  }

  //api: https://api.opencagedata.com/geocode/v1/json?q=52.5432379%2C+13.4142133&key=413da2891e5f4c30a4d9ce105931b2fa
  Future<String> getCurrentCity() async {
    final position = await loc();

    final url = Uri.https('api.opencagedata.com', '/geocode/v1/json', {
      'q': '${position.latitude},${position.longitude}',
      'key': '413da2891e5f4c30a4d9ce105931b2fa',
    });

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load city data');
    }

    final data = jsonDecode(response.body);
    final components = data['results'][0]['components'];

    return components['_normalized_city'] ??
        components['neighbourhood'] ??
        components['state'] ??
        components['county'] ??
        components['country'] ??
        'Unknown';
  }

  //api for all quran functions: https://quranapi.pages.dev/api/surah.json

  Future<List<Surah>> fetchQuranList() async {
    final url = Uri.https('quranapi.pages.dev', '/api/surah.json');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load Quran chapters');
    }

    final data = jsonDecode(response.body);
    List<Surah> surahs = [];
    int count = 1;
    for (var item in data) {
      surahs.add(
        Surah(
          count,
          item['surahName'],
          item['surahNameArabic'],
          '${item['revelationPlace']} · ${item['totalAyah']} verses',
        ),
      );
      count++;
    }
    return surahs;
  }

  Future<Surah> fetchSurah(int surahNumber) async {
  final url = Uri.https('quranapi.pages.dev', '/api/surah.json');

  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('Failed to load Surah');
  }

  final data = jsonDecode(response.body);

  final item = data[surahNumber - 1];

  return Surah(
    surahNumber,
    item['surahName'],
    item['surahNameArabic'],
    '${item['revelationPlace']} · ${item['totalAyah']} verses',
  );
}

  Future<List<Ayah>> fetchSurahAyahs(int surahNumber) async {
    final url = Uri.https('quranapi.pages.dev', '/api/$surahNumber.json');

    final response = await http.get(
      url,
      headers: {'User-Agent': 'sakina_app/1.0 (alqadomiyousef@gmail.com)'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load Surah ayahs (status ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body);

    final arabic = data['arabic1'] as List;
    final english = data['english'] as List;

    final length = arabic.length < english.length
        ? arabic.length
        : english.length;

    List<Ayah> ayahs = [];

    for (int i = 0; i < length; i++) {
      ayahs.add(Ayah(i + 1, english[i], arabic[i]));
    }

    return ayahs;
  }

  Future<String> fetchAudioUrl(int surahNumber) async {
    final url = Uri.https('quranapi.pages.dev', '/api/$surahNumber.json');

    final response = await http.get(
      url,
      headers: {'User-Agent': 'sakina_app/1.0 (alqadomiyousef@gmail.com)'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load audio URL');
    }
    final data = jsonDecode(response.body);
    return data['audio']['4']['url'];
  }

  Future<String> fetchverse(int surahNumber, int ayah) async {
    final url = Uri.https('quranapi.pages.dev', '/api/$surahNumber/$ayah.json');

    final response = await http.get(
      url,
      headers: {'User-Agent': 'sakina_app/1.0 ()'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load verse');
    }
    final data = jsonDecode(response.body);
    return data['audio']['4']['url'];
  }






  
  // used api: https://overpass-api.de/api/interpreter?data=%20[out:json];%20(%20node[%22amenity%22=%22place_of_worship%22][%22religion%22=%22muslim%22](around:3000,32.06693922167334,35.8842368);%20way[%22amenity%22=%22place_of_worship%22][%22religion%22=%22muslim%22](around:3000,31.9684608,35.91088444203066);%20);%20out%20center;
  // everything below is for fetching nearby mosques using Overpass API, dont change it, it breaks a lot
  // also it might take a long time to load, problem with Overpass API servers
  Future<http.Response> _postOverpass(String query) async {
    for (final server in _overpassServers) {
      try {
        final response = await _postWithRetry(Uri.parse(server), query);
        return response;
      } catch (_) {
        //next
      }
    }
    throw Exception('All Overpass servers failed');
  }

  Future<http.Response> _postWithRetry(
    Uri url,
    String body, {
    int retries = 3,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'text/plain; charset=UTF-8'},
          body: body,
        );
        if (response.statusCode == 200) return response;
        throw Exception('HTTP ${response.statusCode}');
      } catch (e) {
        attempt++;
        if (attempt >= retries) rethrow;
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  Future<List<Mosque>> fetchNearbyMosques({int limit = 15}) async {
    final position = await loc();
    final lat = position.latitude;
    final lon = position.longitude;

    final cacheKey = '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

    final cached = _mosqueCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    final query =
        '''
[out:json];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:3000,$lat,$lon);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:3000,$lat,$lon);
);
out center;
''';

    final response = await _postOverpass(query);
    final decoded = jsonDecode(response.body);
    final List elements = decoded['elements'];

    if (elements.isEmpty) return [];

    final nodes = elements.where((e) => e['type'] == 'node').toList();
    final ways = elements.where((e) => e['type'] == 'way').toList();
    final List candidates = nodes.isNotEmpty ? nodes : ways;

    final List<Mosque> mosques = [];

    for (var m in candidates) {
      final latM = m['lat'] ?? m['center']?['lat'];
      final lonM = m['lon'] ?? m['center']?['lon'];
      if (latM == null || lonM == null) continue;

      final distance = Geolocator.distanceBetween(lat, lon, latM, lonM);
      final tags = m['tags'] ?? {};

      final name = _resolveMosqueName(tags, distance);
      final address = _resolveAddress(tags);
      final mapsLink =
          'https://www.google.com/maps/dir/?api=1&destination=$latM,$lonM';

      mosques.add(Mosque(name, distance, address, mapsLink));
    }

    mosques.sort((a, b) => a.distance.compareTo(b.distance));
    final result = mosques.take(limit).toList();

    _mosqueCache[cacheKey] = _CacheEntry(result);
    return result;
  }

  String _resolveMosqueName(Map tags, double distance) {
    return tags['name'] ??
        tags['name:ar'] ??
        tags['name:en'] ??
        'Nearby Mosque (${(distance / 1000).toStringAsFixed(1)} km)';
  }

  String _resolveAddress(Map tags) {
    return tags['addr:street'] ??
        tags['addr:neighbourhood'] ??
        tags['addr:city'] ??
        'Address unavailable';
  }
}

// the classes are here to make it easier to send data between files,
class Surah {
  final int number;
  final String nameEn;
  final String nameAr;
  final String info;

  Surah(this.number, this.nameEn, this.nameAr, this.info);
}

class Ayah {
  final int number;
  final String eng;
  final String ar;

  Ayah(this.number, this.eng, this.ar);
}

class Mosque {
  final String name;
  final double distance;
  final String address;
  final String mapsLink;
  Mosque(this.name, this.distance, this.address, this.mapsLink);
}

class _CacheEntry<T> {
  final T data;
  final DateTime timestamp = DateTime.now();

  _CacheEntry(this.data);

  bool get isExpired => DateTime.now().difference(timestamp) > API._cacheTTL;
}
