import 'package:get/get.dart';
import '../../../data/models/network_response.dart';
import '../../../data/services/network_caller.dart';
import '../../../data/utility/urls.dart';

class VerifyEmailScreenController extends GetxController {
  String _message = '';

  String get message => _message;

  Future<bool> verifyEmail(String email) async {
    Map<String, dynamic> requestBody = {"email": email};
    final NetworkResponse response =
        await NetworkCaller().postRequest(Urls.sendOTP, requestBody);
    update();
    print(response.isSuccess);
    if (response.isSuccess) {
      return true;
    } else {
      if (response.statusCode == 401) {
        _message = 'not_found_email';
      }
      print(_message);
      return false;
    }
  }
}
