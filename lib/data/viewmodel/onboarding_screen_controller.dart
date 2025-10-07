import 'package:get/get.dart';

class OnboardingScreenController extends GetxController {
  int _currentPageIndex = 0;

  int get currentPageIndex => _currentPageIndex;

  void updatePageIndex(int pageIndex) {
    _currentPageIndex = pageIndex;
    update();
  }
}
