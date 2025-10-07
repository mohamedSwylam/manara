import 'dart:developer';
import 'package:get/get.dart';
import '../../data/models/event_prayer_category_data_list_model.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utility/urls.dart';

class EventPrayerCategoryDataListController extends GetxController {
  String _errorMessage = '';
  final List<EventPrayerCategoryDataListModel> _eventPrayerCategoryDataList = [];

  String get errorMessage => _errorMessage;

  List<EventPrayerCategoryDataListModel> get eventPrayerCategoryDataList =>
      _eventPrayerCategoryDataList;

  Future<bool> getEventPrayerCategoryData(String categoryName) async {
    update();
    final NetworkResponse response = await NetworkCaller()
        .getRequest(Urls.getEventPrayerCategoryData(categoryName));
    update();
    if (response.isSuccess) {
      List<dynamic> dataList = response.responseJson;
      _eventPrayerCategoryDataList.clear();
      for (var data in dataList) {
        _eventPrayerCategoryDataList
            .add(EventPrayerCategoryDataListModel.fromJson(data));
      }
      update();
      log(_eventPrayerCategoryDataList.length.toString());
      return true;
    } else {
      _errorMessage = 'Event Prayer category data get failed!';
      return false;
    }
  }
}
