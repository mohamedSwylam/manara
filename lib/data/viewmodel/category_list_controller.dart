import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../data/models/al_quran_surah/surah_list_model.dart';
import '../../data/models/category_list_model.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utility/urls.dart';


class CategoryListController extends GetxController {
  bool _categoryDataFetchInProgress = false;
  String _errorMessage = '';
  final List<CategoryListModel> _categoryList = [];
  SurahListModel _surahListModel = SurahListModel();

  SurahListModel get surahListModel => _surahListModel;

  bool get categoryDataFetchInProgress => _categoryDataFetchInProgress;

  String get errorMessage => _errorMessage;

  List<CategoryListModel> get categoryList => _categoryList;

  Future<bool> getCategoryList(String categoryURL) async {
    _categoryDataFetchInProgress = true;
    update();
    final NetworkResponse response = await NetworkCaller().getRequest(
        categoryURL == 'AL-QURAN'
            ? Urls.getSurahList
            : Urls.getCategoryList(categoryURL));
    debugPrint("~~~~~~~~~~~~~~~~~~${response.statusCode}");
    _categoryDataFetchInProgress = false;
    update();
    if (categoryURL == 'AL-QURAN') {
      if (response.isSuccess) {
        _surahListModel = SurahListModel.fromJson(response.responseJson);
        update();
        return true;
      } else {
        _errorMessage = 'Quran data get failed!';
        update();
        return false;
      }
    } else {
      if (response.isSuccess) {
        List<dynamic> dataList = response.responseJson;
        _categoryList.clear();
        for (var data in dataList) {
          _categoryList.add(CategoryListModel.fromJson(data));
        }
        update();
        log(_categoryList.length.toString());
        return true;
      } else {
        _errorMessage = 'Category data get failed!';
        _categoryList.clear();
        update();
        return false;
      }
    }
  }
}
