import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';


import '../../../constants/images.dart';
import '../../../data/bloc/book_details/book_details_state.dart';
import 'widgets/hadith_reading_card.dart';
import 'widgets/chapter_dropdown.dart';

class BookReadingScreen extends StatefulWidget {
  final String bookId;
  final String bookName;
  final List<BookChapter> chapters;

  const BookReadingScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.chapters,
  });

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {
  BookChapter? selectedChapter;
  List<HadithReadingData> hadithList = [];
  bool isLoading = false;
  int currentChapterIndex = 0;
  bool hasMoreChapters = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.chapters.isNotEmpty) {
      selectedChapter = widget.chapters[0];
      currentChapterIndex = 0;
      _loadHadithForChapter(selectedChapter!);
    }
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading && hasMoreChapters) {
        _loadNextChapter();
      }
    }
  }

  void _loadHadithForChapter(BookChapter chapter) {
    setState(() {
      isLoading = true;
    });

    // Simulate API call to load hadith for the selected chapter
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Always replace the list when loading a specific chapter
        hadithList = _generateHadithData(chapter);
        isLoading = false;
      });
    });
  }

    List<Widget> _buildSliverList() {
    List<Widget> slivers = [];
    
    // Group hadith by chapter
    Map<int, List<HadithReadingData>> chaptersMap = {};
    for (var hadith in hadithList) {
      if (!chaptersMap.containsKey(hadith.chapterNumber)) {
        chaptersMap[hadith.chapterNumber] = [];
      }
      chaptersMap[hadith.chapterNumber]!.add(hadith);
    }
    
    // Create slivers for each chapter
    chaptersMap.forEach((chapterNumber, hadithList) {
      final chapter = widget.chapters.firstWhere((c) => c.chapterNumber == chapterNumber);

      slivers.add(
        MultiSliver(
          pushPinnedChildren: true,
          children: [
        SliverPinnedHeader(
            child: _ChapterHeaderDelegate(
              chapter: chapter,
              minHeight: 60.h,
              maxHeight: 80.h,
            ),
        ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: HadithReadingCard(hadith: hadithList[index]),
                  );
                },
                childCount: hadithList.length,
              ),
            ),
          ],
        ),
      );
    });
    
    return slivers;
  }

  List<HadithReadingData> _generateHadithData(BookChapter chapter) {
    // Generate sample hadith data for the chapter
    return [
      HadithReadingData(
        id: '${chapter.id}_1',
        chapterNumber: chapter.chapterNumber,
        chapterTitle: chapter.name,
        hadithNumber: 1,
        narrator: 'حَدَّثَنَا عُبَيْدُ اللَّهِ بْنُ مُوسَى',
        arabicText: 'بَابُ الإِيمَانِ وَقَوْلِ النَّبِيِّ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: بُنِيَ الْإِسْلَامُ عَلَى خَمْسٍ»',
        englishText: 'Narrated Ibn \'Umar: Allah\'s Messenger (ﷺ) said: Islam is based on (the following) five (principles):',
        explanation: '1. To testify that none has the right to be worshipped but Allah and Muhammad is Allah\'s Messenger (ﷺ).\n2. To offer the (compulsory congregational) prayers dutifully and perfectly.\n3. To pay Zakat (i.e. obligatory charity).\n4. To perform Hajj. (i.e. Pilgrimage to Mecca)\n5. To observe fast during the month of Ramadan.',
      ),
      HadithReadingData(
        id: '${chapter.id}_2',
        chapterNumber: chapter.chapterNumber,
        chapterTitle: chapter.name,
        hadithNumber: 2,
        narrator: 'حَدَّثَنَا أَبُو بَكْرِ بْنُ أَبِي شَيْبَةَ',
        arabicText: 'باب دُعَاؤُكُمْ إِيمَانُكُمْ',
        englishText: 'Narrated Abu Huraira: The Prophet said, "Faith has over seventy branches..."',
        explanation: 'The Prophet (ﷺ) explained that faith has many aspects and branches, including belief in Allah, His angels, His books, His messengers, the Last Day, and divine decree.',
      ),
      HadithReadingData(
        id: '${chapter.id}_3',
        chapterNumber: chapter.chapterNumber,
        chapterTitle: chapter.name,
        hadithNumber: 3,
        narrator: 'حَدَّثَنَا مُحَمَّدُ بْنُ عَبْدِ اللَّهِ',
        arabicText: 'باب الإِيمَانُ بِاللَّهِ وَرَسُولِهِ',
        englishText: 'Narrated Anas: The Prophet said, "Seeking knowledge is obligatory..."',
        explanation: 'The Prophet (ﷺ) emphasized the importance of seeking knowledge and understanding the religion.',
      ),
      HadithReadingData(
        id: '${chapter.id}_4',
        chapterNumber: chapter.chapterNumber,
        chapterTitle: chapter.name,
        hadithNumber: 4,
        narrator: 'حَدَّثَنَا أَحْمَدُ بْنُ حَنْبَلٍ',
        arabicText: 'باب الإِيمَانُ بِاللَّهِ وَرَسُولِهِ وَالْيَوْمِ الآخِرِ',
        englishText: 'Narrated Abu Huraira: The Prophet said, "Whoever believes in Allah and His Messenger..."',
        explanation: 'The Prophet (ﷺ) emphasized the importance of complete faith in Allah, His Messenger, and the Last Day.',
      ),
      HadithReadingData(
        id: '${chapter.id}_5',
        chapterNumber: chapter.chapterNumber,
        chapterTitle: chapter.name,
        hadithNumber: 5,
        narrator: 'حَدَّثَنَا عَبْدُ اللَّهِ بْنُ مَسْعُودٍ',
        arabicText: 'باب الإِيمَانُ بِاللَّهِ وَرَسُولِهِ وَالْكِتَابِ',
        englishText: 'Narrated Ibn Abbas: The Prophet said, "Faith is knowledge and action..."',
        explanation: 'The Prophet (ﷺ) explained that true faith combines both knowledge and righteous actions.',
      ),
    ];
  }

  void _onChapterChanged(BookChapter chapter) {
    setState(() {
      selectedChapter = chapter;
      currentChapterIndex = widget.chapters.indexOf(chapter);
      hasMoreChapters = currentChapterIndex < widget.chapters.length - 1;
    });
    _loadHadithForChapter(chapter);
  }

  void _loadNextChapter() {
    if (currentChapterIndex < widget.chapters.length - 1 && !isLoading) {
      setState(() {
        currentChapterIndex++;
        selectedChapter = widget.chapters[currentChapterIndex];
        hasMoreChapters = currentChapterIndex < widget.chapters.length - 1;
        // Append the next chapter's hadith to the existing list
        hadithList.addAll(_generateHadithData(selectedChapter!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: ChapterDropdown(
          chapters: widget.chapters,
          selectedChapter: selectedChapter,
          onChapterChanged: _onChapterChanged,
        ),
        centerTitle: false,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              SizedBox(width: 8.w), // Small spacing between dropdown and bookmark
              IconButton(
                icon: Icon(Icons.bookmark_border, color: theme.iconTheme.color),
                onPressed: () {
                  // TODO: Add bookmark functionality
                  print('Bookmark pressed');
                },
              ),
            ],
          ),
        ],
      ),
            body: isLoading
           ? const Center(
               child: CircularProgressIndicator(),
             )
           : Padding(
               padding: EdgeInsets.symmetric(horizontal: 16.w),
               child: CustomScrollView(
                 controller: _scrollController,
                 slivers: [
                   MultiSliver(
                     pushPinnedChildren: true,
                     children: <Widget>[
                       ..._buildSliverList(),
                     ],
                   ),
                  // Loading indicator for next chapter
                  if (isLoading && hasMoreChapters)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                   // SliverToBoxAdapter(
                   //   child: SizedBox(height: 800.h),
                   // )
                ],
               ),
             ),
    );
  }
}

// Data model for hadith reading
class HadithReadingData {
  final String id;
  final int chapterNumber;
  final String chapterTitle;
  final int hadithNumber;
  final String narrator;
  final String arabicText;
  final String englishText;
  final String explanation;

  HadithReadingData({
    required this.id,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.hadithNumber,
    required this.narrator,
    required this.arabicText,
    required this.englishText,
    required this.explanation,
  });
}

class _ChapterHeaderDelegate extends StatelessWidget {
  final BookChapter chapter;
  final double minHeight;
  final double maxHeight;

  _ChapterHeaderDelegate({
    required this.chapter,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxHeight,
      color: const Color(0xFFF3EEE7),
      child: Center(
        child: Text(
          '${chapter.chapterNumber}. ${chapter.name}',
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
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
