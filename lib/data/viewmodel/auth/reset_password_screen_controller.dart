import 'package:get/get.dart';
import '../../../data/models/network_response.dart';
import '../../../data/services/network_caller.dart';
import '../../../data/utility/urls.dart';

class ResetPasswordScreenController extends GetxController {
  String _message = '';

  String get message => _message;

  Future<bool> resetPassword(
      String email, String newPassword, String otpString) async {
    int otpInt = int.parse(otpString);
    update();
    Map<String, dynamic> requestBody = {
      "email": email,
      "newPassword": newPassword,
      "otp": otpInt
    };
    final NetworkResponse response =
        await NetworkCaller().updateRequest(Urls.resetPassword, requestBody, false);
    update();
    print(response.isSuccess);
    if (response.isSuccess) {
      return true;
    } else {
      if (response.statusCode == 404) {
        _message = 'user_not_found';
      } else {
        if (response.statusCode == 401) {
          _message = 'otp_not_match';
        }
      }
      print(_message);
      return false;
    }
  }
}
