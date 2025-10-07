import 'package:get/get.dart';
import 'package:manara/data/viewmodel/auth/user_data_controller.dart';

import '../../../data/models/network_response.dart';
import '../../../data/services/network_caller.dart';
import '../../../data/utility/urls.dart';
import '../../utility/token_manager.dart';

class SignInScreenController extends GetxController {
  String _message = '';
  String _token = '';

  String get message => _message;

  Future<bool> signIn(String email, String password, String userAdId) async {
    update();
    print("~~~~~~~~~~~~~~~~~~~$email~~~$password~~~$userAdId");
    Map<String, dynamic> requestBody = {
      "email": email,
      "password": password,
      "oneSignalId": userAdId.isEmpty ? 6969 : userAdId,
    };
    final NetworkResponse response =
        await NetworkCaller().postRequest(Urls.signIn, requestBody);
    update();
    print(response.isSuccess);
    if (response.isSuccess) {
      /*await AuthController.clearTokenValue();
      _token = response.responseJson['token'];*/
      await AuthController.setAccessToken(_token);
      await UserDataController.setUserId(response.responseJson['_id']);
      await UserDataController.setUserName(response.responseJson['fullName']);
      await UserDataController.setUserMail(response.responseJson['email']);
      DateTime expireTime = DateTime.now().add(const Duration(days: 6));
      await AuthController.setExpireDateAndTime(expireTime.toString());
      // print(response.responseJson['user']['_id']);
      // print(response.responseJson['user']['fullName']);
      // print(response.responseJson['user']['email']);
      print(_token);
      return true;
    } else {
      if (response.statusCode == 404) {
        _message = 'user_not_found';
      } else {
        if (response.statusCode == 401) {
          _message = 'invalid_password';
        } else {
          _message = 'Something went wrong';
        }
      }
      print(_message);
      return false;
    }
  }
}
