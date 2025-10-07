import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../constants/images.dart';

class QuranCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isLeftCard;

  const QuranCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isLeftCard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      width: 160.w,
      height: 95.h,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isLeftCard) ...[
            // Mosque/minaret background for left card
            Positioned(
              bottom: 0,
              left: isRTL ? 10.w : null,
              right: isRTL ? null : 10.w,
              child: SvgPicture.asset(
                AssetsPath.iconTransparent,
                width: 55.w,
                height: 60.h,
              ),
            ),
          ] else ...[
            // Bookmark icon for right card
            Positioned(
              bottom: 8.h,
              left: isRTL ? 8.w : null,
              right: isRTL ? null : 8.w,
              child: Icon(
                Icons.bookmark,
                size: 20.sp,
                color: const Color(0xFFA7805A),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Align(
                  alignment:
                      isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          theme.textTheme.titleMedium?.color ?? Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
                SizedBox(height: 2.h),
                // Subtitle
                Align(
                  alignment:
                      isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.textTheme.bodySmall?.color ?? Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
                SizedBox(height: 8.h),

                // Status
                Align(
                  alignment:
                      isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFA7805A),
                    ),
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
