import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import '../models/network_response.dart';
import '../utility/token_manager.dart';
import 'package:http/http.dart' as http;

class NetworkCaller {
  /// get request method
  Future<NetworkResponse> getRequest(String url, {bool isLogin = false}) async {
    try {
      print(url);
      print(Uri.parse(url));
      Response response = await get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${AuthController.accessToken}'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          true,
          response.statusCode,
          //jsonDecode(await response.stream.bytesToString()),
          jsonDecode(response.body),
        );
      } else {
        log('Error occurred');
        return NetworkResponse(false, response.statusCode, null);
      }
    } catch (e) {
      log(e.toString());
    }
    return NetworkResponse(false, -1, null);
  }

  /// Post request method
  Future<NetworkResponse> postRequest(String url, Map<String, dynamic> body,
      {bool isLogin = false}) async {
    try {
      MultipartRequest request = MultipartRequest('POST', Uri.parse(url));
      request.fields['data'] = jsonEncode(body);
      StreamedResponse response = await request.send();
      //log(response.statusCode.toString());
      //log(await response.stream.bytesToString());
      print(url);
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          true,
          response.statusCode,
          jsonDecode(await response.stream.bytesToString()),
        );
      } else {
        log('I am error');
        return NetworkResponse(
          false,
          response.statusCode,
          null,
        );
      }
    } catch (e) {
      log(e.toString());
    }
    return NetworkResponse(false, -1, null);
  }

  /// PATCH request method
  Future<NetworkResponse> updateRequest(String url, Map<String, dynamic> body, bool imageUpload, {File? file}
      ) async {
    try {
      print("----------------------$body");
      print("----------------------$url");
      print("----------------------${file}");
      MultipartRequest request = MultipartRequest('POST', Uri.parse(url));
      // Add headers, including Accept: */*
      request.headers.addAll({
        'Accept': 'application/json',
      });

      request.fields['data'] = jsonEncode(body);
      if(imageUpload && file != null){
        request.files.add(await MultipartFile.fromPath('file', file.path));
      }
      StreamedResponse response = await request.send();
      //log(response.statusCode.toString());
      //log(await response.stream.bytesToString());
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          true,
          response.statusCode,
          jsonDecode(await response.stream.bytesToString()),
        );
      } else {
        log('I am error');
        return NetworkResponse(
          false,
          response.statusCode,
          null,
        );
      }
    } catch (e) {
      log(e.toString());
    }
    return NetworkResponse(false, -1, null);
  }
}
