import 'package:get/get.dart';
import '../../../data/models/network_response.dart';
import '../../../data/services/network_caller.dart';
import '../../../data/utility/urls.dart';

class OtpVerificationController extends GetxController {
  String _message = '';

  String get message => _message;

  Future<bool> verifyOtp(String email, String otpString) async {
    int otpInt = int.parse(otpString);
    update();
    Map<String, dynamic> requestBody = {"email": email, "otp": otpInt};
    final NetworkResponse response =
        await NetworkCaller().postRequest(Urls.verifyOTP, requestBody);
    update();
    print(response.isSuccess);
    if (response.isSuccess) {
      return true;
    } else {
      if (response.statusCode == 401) {
        _message = 'otp_not_match';
      }
      print(_message);
      return false;
    }
  }
}
