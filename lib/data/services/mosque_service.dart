import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/mosque_model.dart';

class MosqueService {
  static const String _baseUrl =
      'https://api.example.com'; // Replace with your API endpoint
  static const String _googlePlacesApiKey =
      'AIzaSyD2BGWy5q1Hl_3ZQIsn9XfBX6_QisZHTMI'; // Replace with your API key

  // Cache to prevent duplicate API calls with expiry
  static final Map<String, Map<String, dynamic>> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  // Helper method to check if cache entry is valid
  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final entry = _cache[key]!;
    final timestamp = entry['timestamp'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < _cacheExpiry.inMilliseconds;
  }

  // Helper method to get cached data
  static List<MosqueModel>? _getCachedData(String key) {
    if (!_isCacheValid(key)) return null;
    return _cache[key]!['data'] as List<MosqueModel>;
  }

  // Helper method to set cached data
  static void _setCachedData(String key, List<MosqueModel> data) {
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Clean up expired cache entries (keep only last 10 entries)
    if (_cache.length > 10) {
      final sortedEntries = _cache.entries.toList()
        ..sort((a, b) => (a.value['timestamp'] as int)
            .compareTo(b.value['timestamp'] as int));

      // Remove oldest entries
      for (int i = 0; i < sortedEntries.length - 10; i++) {
        _cache.remove(sortedEntries[i].key);
      }
    }
  }

  // Method to clear expired cache entries
  static void _clearExpiredCache() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      final timestamp = entry.value['timestamp'] as int;
      if ((now - timestamp) >= _cacheExpiry.inMilliseconds) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      print('🧹 Cleared ${expiredKeys.length} expired cache entries');
    }
  }

  /// Fetch nearby mosques using Google Places API
  static Future<List<MosqueModel>> getNearbyMosques(
      double latitude, double longitude) async {
    // Clear expired cache entries
    _clearExpiredCache();

    // Create cache key based on location (rounded to 2 decimal places for caching)
    final cacheKey =
        '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';

    // Check cache first
    final cachedData = _getCachedData(cacheKey);
    if (cachedData != null) {
      print('📋 Returning cached mosque data for: $cacheKey');
      return cachedData;
    }

    try {
      print('🔄 Fetching nearby mosques for location: $latitude, $longitude');

      // Option 1: Using Google Places API (requires API key and billing)
      try {
        print("Mosque $latitude $longitude");
        final mosques =
            await _getNearbyMosquesFromGooglePlaces(latitude, longitude);
        if (mosques.isNotEmpty) {
          print('✅ Found ${mosques.length} mosques from Google Places API');
          _setCachedData(cacheKey, mosques); // Cache the result
          return mosques;
        }
      } catch (e) {
        print('⚠️ Google Places API failed: $e');
      }

      // Option 2: Using OpenStreetMap Overpass API (free) as fallback
      // Skip this for now as it's hanging - go directly to sample data
      print('⚠️ Skipping OpenStreetMap API (known to hang), using sample data');

      // Option 3: Return sample mosque data as fallback
      final sampleData = _getSampleMosqueData(latitude, longitude);
      _setCachedData(cacheKey, sampleData); // Cache the result
      return sampleData;
    } catch (e) {
      print('❌ Error fetching nearby mosques: $e');
      final sampleData = _getSampleMosqueData(latitude, longitude);
      _setCachedData(cacheKey, sampleData); // Cache the result
      return sampleData;
    }
  }

  /// Fetch nearby mosques using Google Places API
  static Future<List<MosqueModel>> _getNearbyMosquesFromGooglePlaces(
      double lat, double lng) async {
    try {
      print('Calling Google Places API for location: $lat, $lng');

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
          'location=$lat,$lng&'
          // 'radius=5000&'
          'rankby=distance&'
          'type=Mosque&'
          'key=$_googlePlacesApiKey');

      print('Google Places API URL: $url');
      final response = await http.get(url);

      print('Google Places API response status: ${response.statusCode}');
      print('Google Places API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String;

        if (status == 'REQUEST_DENIED' || status == 'INVALID_REQUEST') {
          print('Google Places API access denied or invalid request: $status');
          print(
              'This usually means the API key is invalid or billing is not enabled');
          return [];
        }

        if (status == 'ZERO_RESULTS') {
          print('No mosques found in the area');
          return [];
        }

        final results = data['results'] as List;
        print('Google Places API found ${results.length} results');

        return results.map((place) {
          final location = place['geometry']['location'];
          final distance =
              _calculateDistance(lat, lng, location['lat'], location['lng']);

          return MosqueModel(
            name: place['name'] ?? 'مسجد',
            location: place['vicinity'] ?? 'موقع غير محدد',
            distance: '${distance.toStringAsFixed(1)} كم',
            latitude: location['lat'].toDouble(),
            longitude: location['lng'].toDouble(),
          );
        }).toList();
      }

      print('Google Places API failed with status: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching from Google Places: $e');
      return [];
    }
  }

  /// Fetch nearby mosques using OpenStreetMap Overpass API (free)
  static Future<List<MosqueModel>> _getNearbyMosquesFromOpenStreetMap(
      double lat, double lng) async {
    try {
      print('Calling OpenStreetMap API for location: $lat, $lng');

      final radius = 5000; // 5km radius
      final query = '''
        [out:json][timeout:25];
        (
          node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
          way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
          relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,$lat,$lng);
        );
        out body;
        >>;
        out skel qt;
      ''';

      print('OpenStreetMap query: $query');
      final url = Uri.parse('https://overpass-api.de/api/interpreter');
      final response = await http.post(url, body: query);

      print('OpenStreetMap API response status: ${response.statusCode}');
      print('OpenStreetMap API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        print('OpenStreetMap API found ${elements.length} elements');

        final mosques = elements
            .where((element) =>
                element['tags'] != null && element['tags']['name'] != null)
            .map((element) {
          final distance =
              _calculateDistance(lat, lng, element['lat'], element['lon']);

          return MosqueModel(
            name: element['tags']['name'] ?? 'مسجد',
            location: element['tags']['addr:street'] ?? 'موقع غير محدد',
            distance: '${distance.toStringAsFixed(1)} كم',
            latitude: element['lat'].toDouble(),
            longitude: element['lon'].toDouble(),
          );
        }).toList();

        print(
            'OpenStreetMap API found ${mosques.length} mosques after filtering');
        return mosques;
      }

      print('OpenStreetMap API failed with status: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching from OpenStreetMap: $e');
      return [];
    }
  }

  /// Fetch nearby mosques using custom API
  static Future<List<MosqueModel>> _getNearbyMosquesFromCustomAPI(
      double lat, double lng) async {
    try {
      final url =
          Uri.parse('$_baseUrl/mosques/nearby?lat=$lat&lng=$lng&radius=5000');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mosques = data['mosques'] as List;

        return mosques.map((mosque) {
          final distance = _calculateDistance(
              lat, lng, mosque['latitude'], mosque['longitude']);

          return MosqueModel(
            name: mosque['name'] ?? 'مسجد',
            location: mosque['address'] ?? 'موقع غير محدد',
            distance: '${distance.toStringAsFixed(1)} كم',
            latitude: mosque['latitude'].toDouble(),
            longitude: mosque['longitude'].toDouble(),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching from custom API: $e');
      return [];
    }
  }

  /// Calculate distance between two points using Haversine formula
  static double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(_degreesToRadians(lat1)) *
            math.sin(_degreesToRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Generate sample mosque data as fallback
  static List<MosqueModel> _getSampleMosqueData(
      double latitude, double longitude) {
    print(
        '📋 Generating sample mosque data for location: $latitude, $longitude');

    // Generate mosques at different distances from the user's location
    final mosques = <MosqueModel>[];

    // Determine location name based on coordinates
    String locationName = _getLocationNameFromCoordinates(latitude, longitude);

    // Calculate nearby coordinates (within 5km radius)
    final nearbyCoordinates = [
      {
        'lat': latitude + 0.001,
        'lng': longitude + 0.001,
        'name': 'مسجد السلام',
        'distance': '0.2 km'
      },
      {
        'lat': latitude - 0.002,
        'lng': longitude + 0.003,
        'name': 'مسجد النور',
        'distance': '0.5 km'
      },
      {
        'lat': latitude + 0.003,
        'lng': longitude - 0.001,
        'name': 'مسجد الرحمن',
        'distance': '0.8 km'
      },
      {
        'lat': latitude - 0.004,
        'lng': longitude - 0.002,
        'name': 'مسجد الفتح',
        'distance': '1.2 km'
      },
      {
        'lat': latitude + 0.005,
        'lng': longitude + 0.004,
        'name': 'مسجد التقوى',
        'distance': '1.8 km'
      },
    ];

    for (int i = 0; i < nearbyCoordinates.length; i++) {
      final coord = nearbyCoordinates[i];
      mosques.add(MosqueModel(
        name: coord['name'] as String,
        location: locationName,
        distance: coord['distance'] as String,
        latitude: coord['lat'] as double,
        longitude: coord['lng'] as double,
      ));
    }

    print('✅ Generated ${mosques.length} sample mosques for $locationName');
    return mosques;
  }

  /// Get location name based on coordinates
  static String _getLocationNameFromCoordinates(
      double latitude, double longitude) {
    // Check if coordinates are in Egypt (Cairo area)
    if (latitude >= 29.0 &&
        latitude <= 31.0 &&
        longitude >= 30.0 &&
        longitude <= 32.0) {
      return 'القاهرة، مصر';
    }
    // Check if coordinates are in Qatar (Doha area)
    else if (latitude >= 25.0 &&
        latitude <= 26.0 &&
        longitude >= 51.0 &&
        longitude <= 52.0) {
      return 'الدوحة، قطر';
    }
    // Check if coordinates are in Saudi Arabia (Mecca area)
    else if (latitude >= 21.0 &&
        latitude <= 22.0 &&
        longitude >= 39.0 &&
        longitude <= 40.0) {
      return 'مكة المكرمة، السعودية';
    }
    // Check if coordinates are in UAE (Dubai area)
    else if (latitude >= 25.0 &&
        latitude <= 26.0 &&
        longitude >= 55.0 &&
        longitude <= 56.0) {
      return 'دبي، الإمارات';
    }
    // Default fallback
    else {
      return 'موقعك الحالي';
    }
  }
}
