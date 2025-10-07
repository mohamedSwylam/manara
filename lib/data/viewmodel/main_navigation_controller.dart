import 'package:get/get.dart';

class MainNavigationState {
  var currentIndex = 2.obs;

  MainNavigationState();
}

class MainNavigationController extends GetxController {
  final MainNavigationState state = MainNavigationState();
}
