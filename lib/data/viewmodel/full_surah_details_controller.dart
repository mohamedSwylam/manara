import 'dart:developer';

import 'package:get/get.dart';

import '../../data/models/al_quran_surah/full_surah_details_model.dart';
import '../../data/models/network_response.dart';
import '../../data/services/network_caller.dart';
import '../../data/utility/urls.dart';


class FullSurahDetailsController extends GetxController {
  bool _fullSurahFetchInProgress = false;
  String _errorMessage = '';
  List<Verses> _versesList = [];

  String get errorMessage => _errorMessage;

  bool get fullSurahFetchInProgress => _fullSurahFetchInProgress;

  List<Verses>? get versesList => _versesList;

  Future<bool> getFullSurahDetails(int surahNumber) async {
    _fullSurahFetchInProgress = true;
    update();
    final NetworkResponse response =
        await NetworkCaller().getRequest(Urls.getSurahFull(surahNumber));
    _fullSurahFetchInProgress = false;
    update();
    if (response.isSuccess) {
      final data = AlQuranSurahModel.fromJson(response.responseJson);
      _versesList = data.data!.verses!;
      log(_versesList[1].toString());
      update();
      log(_versesList[1].audio.toString());
      return true;
    } else {
      _errorMessage = 'Failed to get full surah data!';
      update();
      return false;
    }
  }
}
