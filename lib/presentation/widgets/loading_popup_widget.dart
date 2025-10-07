import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';

class LoadingPopupWidget extends StatelessWidget {
  const LoadingPopupWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 90.w,
        width: 90.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.colorPrimary,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              spreadRadius: -2.0,
              blurRadius: 4,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.colorWhiteHighEmp,
          ),
        ),
      ),
    );
  }
}
