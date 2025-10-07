import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GPTProvider extends ChangeNotifier{


  //Chat with chat gpt
  String apiUrl = 'https://api.openai.com/v1/chat/completions';
  String model = 'gpt-3.5-turbo';

  String reply = '';
  bool isLoading = false;

  //Send chatGpt one time compilation

  Future<bool> sendCompilation(String nameType, String initialLetter, String apiKey, String language) async {
    isLoading = true;
    notifyListeners();

    var Language = "";

    switch(language){
      case "ar":
        Language = "Arabic";
        break;
      case "tr":
        Language = "Turkish";
        break;
      case "ur":
        Language = "Urdu";
        break;
      case "en":
        Language = "English";
        break;
      case "fr":
        Language = "French";
        break;
      case "bn":
        Language = "Bangla";
        break;
      case "hi":
        Language = "Hindi";
        break;
    }

    final data = {
        "model": "gpt-3.5-turbo",
        "messages":  [
          {
            "role": "system",
            "content": "You will be generating Islamic $nameType names. Do not give any serial number."
          },
          {
            "role": "user",
            "content": "Give 5 Full Islamic $nameType names with the initial letter $initialLetter. Give name in Arabic and $Language and meaning of the name in $Language"
          }
        ]

    };
    debugPrint("LANGUAGE: $Language");

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      debugPrint('ChatGPT response ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('**************');
        debugPrint(response.body);
        debugPrint('**************');
        reply = jsonResponse['choices'][0]['message']['content'];
        return true;
      } else {
        reply = 'Error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      reply = 'Error: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}
