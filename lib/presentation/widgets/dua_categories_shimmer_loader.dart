import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class DuaCategoriesShimmerLoader extends StatelessWidget {
  const DuaCategoriesShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.9,
      ),
      itemCount: 12, // Show 12 shimmer category cards (3x4)
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.brightness == Brightness.dark 
              ? Colors.grey[800]! 
              : Colors.grey[300]!,
          highlightColor: theme.brightness == Brightness.dark 
              ? Colors.grey[700]! 
              : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                                     // Emoji shimmer (circle)
                   Container(
                     height: 40.h,
                     width: 40.w,
                     decoration: const BoxDecoration(
                       color: Colors.white,
                       shape: BoxShape.circle,
                     ),
                   ),
                   SizedBox(height: 8.h),
                  
                                     // Title shimmer
                   Container(
                     height: 14.h,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(4.r),
                     ),
                   ),
                   SizedBox(height: 4.h),
                   
                   // Subtitle shimmer (shorter)
                   Container(
                     height: 10.h,
                     width: MediaQuery.of(context).size.width * 0.2,
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(4.r),
                     ),
                   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
