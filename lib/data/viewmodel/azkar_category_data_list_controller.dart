import 'dart:developer';
import 'package:get/get.dart';
import '../../data/models/azkar_category_data_list_model.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utility/urls.dart';

class AzkarCategoryDataListController extends GetxController {
  String _errorMessage = '';
  final List<AzkarCategoryDataListModel> _azkarCategoryDataList = [];

  String get errorMessage => _errorMessage;

  List<AzkarCategoryDataListModel> get azkarCategoryDataList =>
      _azkarCategoryDataList;

  Future<bool> getAzkarCategoryData(String categoryName) async {
    update();
    final NetworkResponse response = await NetworkCaller()
        .getRequest(Urls.getAzkarCategoryData(categoryName));
    update();
    if (response.isSuccess) {
      List<dynamic> dataList = response.responseJson;
      _azkarCategoryDataList.clear();
      for (var data in dataList) {
        _azkarCategoryDataList.add(AzkarCategoryDataListModel.fromJson(data));
      }
      update();
      log(_azkarCategoryDataList.length.toString());
      return true;
    } else {
      _errorMessage = 'Azkar category data get failed!';
      return false;
    }
  }
}
