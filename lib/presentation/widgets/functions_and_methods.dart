import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../constants/colors.dart';

void makeSnack(String msg) {
  Get.rawSnackbar(
    messageText: Text(
      msg.tr,
      style: const TextStyle(
        color: AppColors.colorPrimary,
        fontSize: 16.0,
      ),
    ),
    backgroundColor: AppColors.colorWhiteHighEmp,
  );
}
