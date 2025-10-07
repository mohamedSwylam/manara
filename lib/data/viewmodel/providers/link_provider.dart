import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:manara/data/utility/urls.dart';

class LinkProvider with ChangeNotifier {
  String liveLink = "";

  Future<void> fetchData() async {
    try {
      // Check if the base URL is properly configured
      if (Urls.liveLink.contains('YOUR BASE URL HERE') || 
          Urls.liveLink.contains('YOUR%20BASE%20URL%20HERE')) {
        print("Base URL not configured. Skipping API call.");
        return;
      }

      final response = await http.get(
        Uri.parse(Urls.liveLink),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Assuming 'live_link' is the key you want to extract
        liveLink = data['live_link'];

        print("*****************Successsss");
        notifyListeners();
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching live link: $e");
      // Don't throw exception to prevent app crash
    }
  }
}
