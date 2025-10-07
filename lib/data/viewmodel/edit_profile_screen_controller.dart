import 'dart:io';
import 'package:get/get.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utility/urls.dart';

class EditProfileScreenController extends GetxController {
  final String _message = '';

  String get message => _message;

  Future<bool> updateUserData(Map<String, dynamic> requestBody, String uId,
      bool imageUpload, File? filePath) async {
    update();
    print(requestBody);
    print(imageUpload);
    final NetworkResponse response = await NetworkCaller().updateRequest(
        Urls.updateUserData(uId), requestBody, imageUpload,
        file: filePath);
    update();
    if (response.isSuccess) {
      return true;
    } else {
      print('Failed update');
      return false;
    }
  }
}
