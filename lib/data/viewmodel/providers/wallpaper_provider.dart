import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../data/utility/urls.dart';

class WallPaperProvider extends ChangeNotifier{
  List<Wallpaper>? _allWallpapers;
  List<Wallpaper>? get allWallpapers => _allWallpapers;

  Future<void> fetchAllWallpapers() async{
    final apiUrl = Urls.fetchWallpapersData; // Replace with your API URL
    final response = await http.get(Uri.parse(apiUrl));
    print("Fetch all wallpapers data with response code ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      _allWallpapers = jsonData.map((json) => Wallpaper.fromJson(json)).toList();
      notifyListeners();
    } else {
      _allWallpapers = [];
    }
  }
}


class Wallpaper {
  final String id;
  final String wallpaperName;
  final String originalUrl;
  final String thumbnailUrl;
  final String timestamp;

  Wallpaper({
    required this.id,
    required this.wallpaperName,
    required this.originalUrl,
    required this.thumbnailUrl,
    required this.timestamp,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      id: json['_id'],
      wallpaperName: json['wallpaperName'],
      originalUrl: json['originalUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'wallpaperName': wallpaperName,
      'originalUrl': originalUrl,
      'thumbnailUrl': thumbnailUrl,
      'timestamp': timestamp,
    };
  }
}
