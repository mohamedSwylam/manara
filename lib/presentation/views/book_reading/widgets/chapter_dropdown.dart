import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/bloc/book_details/book_details_state.dart';

class ChapterDropdown extends StatefulWidget {
  final List<BookChapter> chapters;
  final BookChapter? selectedChapter;
  final Function(BookChapter) onChapterChanged;

  const ChapterDropdown({
    super.key,
    required this.chapters,
    required this.selectedChapter,
    required this.onChapterChanged,
  });

  @override
  State<ChapterDropdown> createState() => _ChapterDropdownState();
}

class _ChapterDropdownState extends State<ChapterDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w, // Increased width
      height: 30.h,
      decoration: BoxDecoration(
        color: const Color(0x1AD5CCA1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFD5CCA1),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BookChapter>(
          value: widget.selectedChapter,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 16.sp,
            color: Colors.black87,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 8.w, // Reduced horizontal padding
            vertical: 6.h,
          ),
          style: GoogleFonts.poppins(
            fontSize: 11.sp, // Slightly smaller font
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(6),
          isExpanded: true, // Make dropdown expand to fill container
          items: widget.chapters.map((BookChapter chapter) {
            return DropdownMenuItem<BookChapter>(
              value: chapter,
              child: Text(
                '${chapter.chapterNumber}. ${chapter.name}',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (BookChapter? newValue) {
            if (newValue != null) {
              widget.onChapterChanged(newValue);
            }
          },
        ),
      ),
    );
  }
}
