import 'dart:developer';
import 'package:get/get.dart';

import '../../data/models/hadith_category_data_list_model.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utility/urls.dart';


class HadithCategoryDataListController extends GetxController {
  String _errorMessage = '';
  final List<HadithCategoryDataListModel> _hadithCategoryDataList = [];

  String get errorMessage => _errorMessage;

  List<HadithCategoryDataListModel> get hadithCategoryDataList =>
      _hadithCategoryDataList;

  Future<bool> getHadithCategoryData(String categoryName) async {
    update();
    final NetworkResponse response = await NetworkCaller()
        .getRequest(Urls.getHadithCategoryData(categoryName));
    update();
    if (response.isSuccess) {
      List<dynamic> dataList = response.responseJson;
      _hadithCategoryDataList.clear();
      for (var data in dataList) {
        _hadithCategoryDataList.add(HadithCategoryDataListModel.fromJson(data));
      }
      update();
      log(_hadithCategoryDataList.length.toString());
      return true;
    } else {
      _errorMessage = 'Hadith category data get failed!';
      return false;
    }
  }
}
