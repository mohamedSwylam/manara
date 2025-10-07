import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../../data/bloc/hadith/hadith_state.dart';
import '../../book_details/book_details_screen.dart';

class HadithCollectionCard extends StatelessWidget {
  final HadithCollection hadith;
  final VoidCallback? onTap;

  const HadithCollectionCard({
    super.key,
    required this.hadith,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap ?? () {
        Get.to(() => BookDetailsScreen(
          bookId: hadith.id,
          bookName: hadith.bookTitle,
        ));
      },
      child: Container(
        width: 328.w,
        height: 122.h,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Book Image
              Container(
                width: 65.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color?.withOpacity(0.3) ?? const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.book,
                    size: 40.sp,
                    color: const Color(0xFF8D1B3D),
                  ),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      hadith.bookTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    Text(
                      hadith.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
