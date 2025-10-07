import 'package:get/get.dart';
import 'package:manara/data/viewmodel/auth/user_data_controller.dart';

import '../../../data/models/network_response.dart';
import '../../../data/services/network_caller.dart';
import '../../../data/utility/urls.dart';
import '../../utility/token_manager.dart';

class SignUpScreenController extends GetxController {
  String _message = '';
  String _token = '';

  String get message => _message;

  Future<bool> signUp(
      String name, String email, String password, String userAdId) async {
    update();
    print("~~~~~~~~~~~~~~~~~~~$name~~~$email~~~$password~~~$userAdId");
    Map<String, dynamic> requestBody = {
      "fullName": name,
      "email": email,
      "password": password,
      "oneSignalId": userAdId.isEmpty ? 6969 : userAdId,
    };
    final NetworkResponse response =
        await NetworkCaller().postRequest(Urls.userSignUp, requestBody);
    update();
    if (response.isSuccess) {
      /*_token = response.responseJson['token'];
      await AuthController.setAccessToken(_token);*/
      await UserDataController.setUserId(response.responseJson['_id']);
      await UserDataController.setUserName(response.responseJson['fullName']);
      await UserDataController.setUserMail(response.responseJson['email']);
      DateTime expireTime = DateTime.now().add(const Duration(days: 6));
      await AuthController.setExpireDateAndTime(expireTime.toString());
      // print(response.responseJson['newUser']['_id']);
      // print(response.responseJson['newUser']['fullName']);
      // print(response.responseJson['newUser']['email']);
      print(_token);
      return true;
    } else {
      if (response.statusCode == 500) {
        _message = 'dup_user';
      } else {
        _message = 'Something went wrong';
      }
      print(_message);
      return false;
    }
  }
}
