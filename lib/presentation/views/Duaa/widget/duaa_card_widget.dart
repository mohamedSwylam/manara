import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manara/constants/colors.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../constants/images.dart';

class DuaaCardWidget extends StatelessWidget {
  final String title;
  final String arabicText;
  final String englishText;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const DuaaCardWidget({
    Key? key,
    required this.title,
    required this.arabicText,
    required this.englishText,
    this.isFavorite = false,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      color: theme.cardTheme.color,
      child: Stack(
        children: [
          /// Background pattern
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: SizedBox(
                  height: 40.h,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth;
                      final iconCount = (cardWidth / 20.w).floor();
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          iconCount,
                          (index) => SvgPicture.asset(
                            AssetsPath.iconTransparent,
                            width: 36.w,
                            height: 42.h,
                            color: AppColors.goldLightColor.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0x33D5CCA1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? AppColors.colorPrimary : theme.iconTheme.color,
                            size: 20.sp,
                          ),
                          onPressed: onFavoriteToggle,
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            AssetsPath.shareSvg,
                            width: 20.w,
                            colorFilter: ColorFilter.mode(
                              theme.iconTheme.color ?? Colors.grey[600]!,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () {
                            Share.share(
                              "Duaa - دعاء\n"
                                  "▶ $arabicText\n"
                                  "▶ $englishText\n",
                              subject: "Manara - منارة",
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          arabicText,
                          style: TextStyle(
                            fontSize: 18.sp,
                            height: 1.5,
                            fontFamily: 'Arabic',
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        englishText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.textTheme.bodyMedium?.color,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
