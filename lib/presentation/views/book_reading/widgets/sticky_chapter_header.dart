import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/bloc/book_details/book_details_state.dart';

class StickyChapterHeader extends StatelessWidget {
  final BookChapter currentChapter;
  final BookChapter? nextChapter;
  final double scrollOffset;
  final double headerHeight;

  const StickyChapterHeader({
    super.key,
    required this.currentChapter,
    this.nextChapter,
    required this.scrollOffset,
    required this.headerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: headerHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEE9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Current chapter title (slides up)
          Positioned(
            top: _calculateCurrentTitleOffset(),
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _calculateCurrentTitleOpacity(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '${currentChapter.chapterNumber}. ${currentChapter.name}',
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: 0,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Next chapter title (slides in from bottom)
          if (nextChapter != null)
            Positioned(
              top: _calculateNextTitleOffset(),
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _calculateNextTitleOpacity(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    '${nextChapter!.chapterNumber}. ${nextChapter!.name}',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      letterSpacing: 0,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _calculateCurrentTitleOffset() {
    // Start at center, move up as scroll progresses
    final progress = (scrollOffset / 200).clamp(0.0, 1.0);
    return 20.h - (progress * 20.h);
  }

  double _calculateCurrentTitleOpacity() {
    // Fade out as next title comes in
    final progress = (scrollOffset / 200).clamp(0.0, 1.0);
    return 1.0 - progress;
  }

  double _calculateNextTitleOffset() {
    // Start below, move to center
    final progress = (scrollOffset / 200).clamp(0.0, 1.0);
    return 40.h - (progress * 20.h);
  }

  double _calculateNextTitleOpacity() {
    // Fade in as scroll progresses
    final progress = (scrollOffset / 200).clamp(0.0, 1.0);
    return progress;
  }
}
