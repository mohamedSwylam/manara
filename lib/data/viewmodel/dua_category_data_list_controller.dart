import 'dart:developer';
import 'package:get/get.dart';
import '../../data/models/dua_category_data_list_model.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utility/urls.dart';

class DuaCategoryDataListController extends GetxController {
  String _errorMessage = '';
  final List<DuaCategoryDataListModel> _duaCategoryDataList = [];

  String get errorMessage => _errorMessage;

  List<DuaCategoryDataListModel> get duaCategoryDataList =>
      _duaCategoryDataList;

  Future<bool> getDuaCategoryData(String categoryName) async {
    update();
    final NetworkResponse response =
        await NetworkCaller().getRequest(Urls.getDuaCategoryData(categoryName));
    update();
    if (response.isSuccess) {
      List<dynamic> dataList = response.responseJson;
      _duaCategoryDataList.clear();
      for (var data in dataList) {
        _duaCategoryDataList.add(DuaCategoryDataListModel.fromJson(data));
      }
      update();
      log(_duaCategoryDataList.length.toString());
      return true;
    } else {
      _errorMessage = 'Dua category data get failed!';
      return false;
    }
  }
}
