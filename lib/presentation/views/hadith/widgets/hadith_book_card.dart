import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../constants/images.dart';
import '../../../../data/bloc/hadith/hadith_state.dart';
import '../../book_details/book_details_screen.dart';

class HadithBookCard extends StatelessWidget {
  final HadithBook? book;
  final bool isLeftCard;

  const HadithBookCard({
    super.key,
    required this.book,
    required this.isLeftCard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (book == null) {
      return Container(
        width: 160.w,
        height: 80.h,
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
        child: Center(
          child: CircularProgressIndicator(
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => BookDetailsScreen(
          bookId: book!.id,
          bookName: book!.title,
        ));
      },
      child: Container(
        width: 160.w,
        height: 90.h,
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
              Positioned(
                bottom: 0,
                right: 10.w,
                child: SvgPicture.asset(
                  AssetsPath.iconTransparent,
                  width: 55.w,
                  height: 60.h,
                ),
              ),
            ],

            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Text(
                    book!.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Type and Count
                  Text(
                    '${book!.type}: ${book!.count}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),

                  // Last Read/Bookmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        book!.lastRead == 'LAST READ' ? 'last_read'.tr : 'last_bookmark'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA7805A),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      if (!isLeftCard) ...[
                        Icon(
                          Icons.bookmark,
                          size: 12.sp,
                          color: const Color(0xFFA7805A),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
