import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../constants/images.dart';
import '../../../../data/bloc/book_details/book_details_state.dart';
import '../../book_reading/book_reading_screen.dart';

class BookChapterItem extends StatelessWidget {
  final BookChapter chapter;
  final String bookName;
  final List<BookChapter> chapters;
  final VoidCallback? onTap;

  const BookChapterItem({
    super.key,
    required this.chapter,
    required this.bookName,
    required this.chapters,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        Get.to(() => BookReadingScreen(
          bookId: chapter.id,
          bookName: bookName,
          chapters: chapters,
        ));
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Book Part SVG with Chapter Number
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AssetsPath.bookPartSVG,
                    width: 40.w,
                    height: 40.h,
                  ),
                  Text(
                    '${chapter.chapterNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      // fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Chapter Name
            Expanded(
              child: Text(
                chapter.name,
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  height: 20 / 15, // line-height: 20px / font-size: 15px
                  letterSpacing: 0,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(width: 16.w),
            
            // Page Numbers
            Text(
              '${chapter.pageStart}-${chapter.pageEnd}',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
