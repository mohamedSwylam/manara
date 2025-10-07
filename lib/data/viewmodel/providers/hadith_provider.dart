import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/dua_category_data_list_model.dart';
import '../../../data/models/hadith_category_data_list_model.dart';
import '../../../data/utility/urls.dart';
import 'package:http/http.dart' as http;

class HadithProvider extends ChangeNotifier {
  String? _language;
  String? get language =>  _language;

  Future<void> getLanguage() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _language = prefs.getString('language');
    notifyListeners();
  }


  List<HadithCategoryDataListModel>? _allHadith;
  List<HadithCategoryDataListModel>? get allHadith => _allHadith;


  //Fetching all hadith data
  Future<void> fetchAllHadithData() async {
    String url = Urls.getAllHadithApi;
    final response = await http.get(Uri.parse(url));
    debugPrint("Fetch all hadith data with response code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _allHadith = data.map((item) => HadithCategoryDataListModel.fromJson(item)).toList();
      getRandomHadithIndex();
      notifyListeners();
    } else {
      debugPrint('Failed to load Single User data: ${response.statusCode}');
    }
  }

  int randomHadithIndex = -1;
  //Getting a randomHadithIndex
  Future<void> getRandomHadithIndex() async{
    randomHadithIndex = Random().nextInt(allHadith!.length);
    notifyListeners();
  }


  List<DuaCategoryDataListModel>? _allDua;
  List<DuaCategoryDataListModel>? get allDua => _allDua;


  //Fetching all hadith data
  Future<void> fetchAllDuaData() async {
    String url = Urls.getAllDuaApi;
    final response = await http.get(Uri.parse(url));
    debugPrint("Fetch all dua data with response code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _allDua = data.map((item) => DuaCategoryDataListModel.fromJson(item)).toList();
      getRandomDuaIndex();
      notifyListeners();
    } else {
      debugPrint('Failed to load Single User data: ${response.statusCode}');
    }
  }

  int randomDuaIndex = -1;
  //Getting a randomHadithIndex
  Future<void> getRandomDuaIndex() async{
    randomDuaIndex = Random().nextInt(allDua!.length);
    notifyListeners();
  }


}
