import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../data/utility/urls.dart';

class UserProvider extends ChangeNotifier{
  UserModel? _userData;
  UserModel? get userData => _userData;

  bool _userDataLoading = false;
  bool get userDataLoading => _userDataLoading;

  Future<void> fetchLoggedInUserData(bool hasUser) async{
    if(hasUser){
      _userDataLoading = true;
      notifyListeners();
      
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString('user_id');
        
        if (userId == null || userId.isEmpty) {
          print('⚠️ No user ID found, using guest mode');
          _setGuestUser();
          return;
        }
        
        String url = "${Urls.fetchUserData}/$userId";
        print('🔗 Fetching user data from: $url');
        
        final response = await http.get(Uri.parse(url));
        print("Fetch user data with response code: ${response.statusCode}");
        
        if(response.statusCode == 200){
          final jsonData = json.decode(response.body);
          _userData = UserModel.fromJson(jsonData);
          _userDataLoading = false;
          notifyListeners();
        } else {
          print('❌ Failed to load user data: ${response.statusCode}');
          _setGuestUser();
        }
      } catch (e) {
        print('❌ Error fetching user data: $e');
        _setGuestUser();
      }
    } else{
      _setGuestUser();
    }
  }

  void _setGuestUser() {
    final dummyData = UserModel(
      fullName: 'Guest User',
      thumbnailUrl: 'Null',
    );
    _userData = dummyData;
    _userDataLoading = false;
    print('✅ Using guest user mode');
    notifyListeners();
  }


  CurrencyData? _allCurrency;
  CurrencyData? get allCurrency => _allCurrency;

// Fetching all currency data
  Future<void> fetchAllCurrencyData() async {
    try {
      String url = Urls.getAllCurrency;
      print('🔗 Fetching currency data from: $url');
      
      final response = await http.get(Uri.parse(url));
      print("Fetch all Currency data with response code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _allCurrency = CurrencyData.fromJson(data);
        notifyListeners();
        print('✅ Currency data loaded successfully');
      } else {
        print('❌ Failed to load Currency data: ${response.statusCode}');
        // Create dummy currency data
        _allCurrency = CurrencyData(
          objectId: 'dummy_id',
          usd: '1.00',
          bdt: '110.00',
          inr: '75.00',
          pkr: '160.00',
          idr: '14000.00',
          tryValue: '8.50',
          myr: '4.20',
          sar: '3.75',
          timestamp: DateTime.now().toIso8601String(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error fetching currency data: $e');
      // Create dummy currency data on error
      _allCurrency = CurrencyData(
        objectId: 'dummy_id',
        usd: '1.00',
        bdt: '110.00',
        inr: '75.00',
        pkr: '160.00',
        idr: '14000.00',
        tryValue: '8.50',
        myr: '4.20',
        sar: '3.75',
        timestamp: DateTime.now().toIso8601String(),
      );
      notifyListeners();
    }
  }



  //Update donation
  Future<void> updateDonationInfo(Donation data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = await prefs.getString('user_id');
    final url = Uri.parse("${Urls.updateDonation}$userId");
    var request = http.MultipartRequest('POST', url);
    request.fields['data'] = jsonEncode(data.toJson());
    var response = await request.send();
    print("Donation data updated with ${response.statusCode}");
  }


}


class UserModel {
  String? id;
  String? fullName;
  String? email;
  String? oneSignalId;
  String? timestamp;
  String? totalDonation;
  String? created_at;
  String? updated_at;
  String? originalUrl;
  String? thumbnailUrl;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.oneSignalId,
    this.timestamp,
    this.totalDonation,
    this.created_at,
    this.updated_at,
    this.originalUrl,
    this.thumbnailUrl,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'].toString(); // Updated for `_id`
    fullName = json['fullName'];
    email = json['email'];
    oneSignalId = json['oneSignalId'];
    timestamp = json['timestamp'];
    totalDonation = json['totalDonation'];
    created_at = json['created_at'];
    updated_at = json['updated_at'];

    // Handle nested fileUrl object
    originalUrl = json['fileUrl']?['originalUrl'];
    thumbnailUrl = json['fileUrl']?['thumbnailUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['fullName'] = fullName;
    data['email'] = email;
    data['oneSignalId'] = oneSignalId;
    data['timestamp'] = timestamp;
    data['totalDonation'] = totalDonation;
    data['created_at'] = created_at;
    data['updated_at'] = updated_at;

    // Handle nested fileUrl object
    data['fileUrl'] = {
      'originalUrl': originalUrl,
      'thumbnailUrl': thumbnailUrl,
    };
    return data;
  }
}



class CurrencyData {
  final String objectId;
  final String usd;
  final String bdt;
  final String inr;
  final String pkr;
  final String idr;
  final String tryValue;
  final String myr;
  final String sar;
  final String timestamp;

  CurrencyData({
    required this.objectId,
    required this.usd,
    required this.bdt,
    required this.inr,
    required this.pkr,
    required this.idr,
    required this.tryValue,
    required this.myr,
    required this.sar,
    required this.timestamp,
  });

  factory CurrencyData.fromJson(Map<String, dynamic> json) {
    return CurrencyData(
      objectId: json['_id'],
      usd: json['USD'],
      bdt: json['BDT'],
      inr: json['INR'],
      pkr: json['PKR'],
      idr: json['IDR'],
      tryValue: json['TRY'],
      myr: json['MYR'],
      sar: json['SAR'],
      timestamp: json['timestamp'],
    );
  }
}





class Donation {
  final int donationAmount;

  Donation({required this.donationAmount});

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      donationAmount: json['donationAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['donationAmount'] = this.donationAmount;
    return data;
  }
}
