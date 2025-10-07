import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../constants/images.dart';
import '../../../data/bloc/book_details/book_details_bloc.dart';
import '../../../data/bloc/book_details/book_details_event.dart';
import '../../../data/bloc/book_details/book_details_state.dart';
import '../../../data/bloc/hadith/hadith_state.dart';
import '../hadith/widgets/bookmark_item.dart';
import '../hadith/widgets/hadith_book_card.dart';
import '../hadith/widgets/hadith_collection_card.dart';
import '../hadith/widgets/search_bar_widget.dart';
import 'widgets/book_chapter_item.dart';
import 'widgets/book_bookmark_item.dart';
import 'widgets/book_search_bar_widget.dart';
import 'widgets/book_details_bottom_sheet.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;
  final String bookName;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    required this.bookName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookDetailsBloc()..add(LoadBookDetails(
        bookId: bookId,
        bookName: bookName,
      )),
      child: BookDetailsView(bookName: bookName),
    );
  }
}

class BookDetailsView extends StatefulWidget {
  final String bookName;

  const BookDetailsView({
    super.key,
    required this.bookName,
  });

  @override
  State<BookDetailsView> createState() => _BookDetailsViewState();
}

class _BookDetailsViewState extends State<BookDetailsView> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showBookDetailsBottomSheet(BuildContext context) {
    // Sample book data - in real app, this would come from the BLoC
    final bookName = widget.bookName;
    final bookNameArabic = _getArabicBookName(bookName);
    final bookDescription = _getBookDescription(bookName);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookDetailsBottomSheet(
        bookName: bookName,
        bookNameArabic: bookNameArabic,
        bookDescription: bookDescription,
      ),
    );
  }

  String _getArabicBookName(String englishName) {
    // Map English book names to Arabic names
    switch (englishName) {
      case 'Sahih al-Bukhari':
        return 'صحيح البخاري';
      case 'Sahih Muslim':
        return 'صحيح مسلم';
      case 'Abu Dawud':
        return 'سنن أبي داود';
      case 'Tirmidhi':
        return 'سنن الترمذي';
      default:
        return englishName;
    }
  }

  String _getBookDescription(String bookName) {
    // Sample descriptions for each book
    switch (bookName) {
      case 'Sahih al-Bukhari':
        return 'صحيح البخاري هو أحد أهم كتب الحديث النبوي عند المسلمين من أهل السنة والجماعة. صنفه الإمام محمد بن إسماعيل البخاري وأتم تأليفه في 256 هـ. يعد أول مصنف في الحديث الصحيح المجرد المنسوب إلى محمد بن عبد الله رسول الديانة الإسلامية، حيث رتبه على الأبواب الفقهية. يعتبر كتاب صحيح البخاري أحد كتب الجوامع وهي التي احتوت على جميع أبواب الحديث من العقائد والأحكام والتفسير والتاريخ والزهد والآداب وغيرها.';
      case 'Sahih Muslim':
        return 'صحيح مسلم هو أحد أهم كتب الحديث النبوي عند المسلمين من أهل السنة والجماعة، جمعه أبو الحسين مسلم بن الحجاج القشيري النيسابوري، أخذ في جمعه من شيوخه من أهل الحديث، وبدأ في جمعه سنة 218 هـ، وانتهى منه سنة 233 هـ، أي أنه استغرق في جمعه خمس عشرة سنة. يعد كتاب صحيح مسلم أحد كتب الجوامع، وهي التي احتوت على جميع أبواب الحديث من العقائد والأحكام والتفسير والتاريخ والزهد والآداب وغيرها.';
      case 'Abu Dawud':
        return 'سنن أبي داود هو كتاب من كتب الحديث النبوي، جمعه أبو داود سليمان بن الأشعث الأزدي السجستاني، وهو من الكتب الستة، وهو كتاب علم، شرح فيه غريب الألفاظ، وعدد كتبه 5274 كتاب، وأحاديثه 5274 حديث.';
      case 'Tirmidhi':
        return 'جامع الترمذي أو سنن الترمذي هو كتاب من كتب الحديث النبوي، جمعه أبو عيسى محمد بن عيسى الترمذي، وهو من الكتب الستة، وهو كتاب علم، شرح فيه غريب الألفاظ، وعدد كتبه 3956 كتاب، وأحاديثه 3956 حديث.';
      default:
        return 'هذا الكتاب من أهم كتب الحديث النبوي الشريف، ويحتوي على أحاديث صحيحة منسوبة إلى النبي محمد صلى الله عليه وسلم.';
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
        centerTitle: true,
        title: Text(
          widget.bookName,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color ?? Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color ?? Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _showBookDetailsBottomSheet(context);
            },
            child: Padding(
              padding: EdgeInsets.only(
                right: 8.w,
                left: 8.w,
              ),
              child: SvgPicture.asset(
                AssetsPath.detailsSvg,
                width: 24.w,
                height: 24.h,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 12.h),
          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF8D1B3D),
            labelColor: theme.textTheme.titleMedium?.color ?? Colors.black,
            unselectedLabelColor: theme.textTheme.bodySmall?.color ?? Colors.black54,
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'book'.tr),
              Tab(text: 'bookmarks'.tr),
            ],
          ),
          
          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
                _tabController.animateTo(index);
              },
              children: [
                // Book Chapters Page
                _buildBookChaptersPage(context),
                
                // Book Bookmarks Page
                _buildBookBookmarksPage(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookChaptersPage(BuildContext context) {
    return BlocBuilder<BookDetailsBloc, BookDetailsState>(
      builder: (context, state) {
        if (state is BookDetailsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is BookDetailsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Error: ${state.message}',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<BookDetailsBloc>().add(LoadBookDetails(
                      bookId: '1',
                      bookName: widget.bookName,
                    ));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is BookDetailsLoaded) {
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(16.w),
                child: BookSearchBarWidget(
                  bookName: state.bookName,
                  onSearch: (query) {
                    context.read<BookDetailsBloc>().add(SearchBookChapters(
                      query: query,
                      bookName: state.bookName,
                    ));
                  },
                ),
              ),
              
              // Chapters List
              Expanded(
                child: ListView.separated(
                  itemCount: state.chapters.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                                     itemBuilder: (context, index) {
                     return BookChapterItem(
                       chapter: state.chapters[index],
                       bookName: state.bookName,
                       chapters: state.chapters,
                     );
                   },
                ),
              ),
            ],
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBookBookmarksPage(BuildContext context) {
    return BlocBuilder<BookDetailsBloc, BookDetailsState>(
      builder: (context, state) {
        if (state is BookDetailsLoaded) {
          if (state.bookmarks.isEmpty) {
            context.read<BookDetailsBloc>().add(LoadBookBookmarks(bookId: '1'));
          }
          
          // Group bookmarks by book title (same as Hadith screen)
          final Map<String, List<BookBookmark>> groupedBookmarks = {};
          for (final bookmark in state.bookmarks) {
            if (!groupedBookmarks.containsKey(bookmark.bookName)) {
              groupedBookmarks[bookmark.bookName] = [];
            }
            groupedBookmarks[bookmark.bookName]!.add(bookmark);
          }
          
          return SingleChildScrollView(
            child: Column(
              children: groupedBookmarks.entries.map((entry) {
                final bookTitle = entry.key;
                final bookmarks = entry.value;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Title Container (same design as Hadith)
                    Container(
                      width: double.infinity,
                      height: 30.h,
                      padding: EdgeInsets.only(top: 3, left: 16.w, right: 16.w),
                      decoration: BoxDecoration(
                        color: const Color(0x1BFFFF83),
                      ),
                      child: Text(
                        bookTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8D1B3D),
                        ),
                      ),
                    ),
                    
                    // Bookmarks List (same design as Hadith)
                    ...bookmarks.map((bookmark) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: BookmarkItem(
                        bookmark: Bookmark(
                          id: bookmark.id,
                          hadithId: bookmark.chapterId,
                          bookTitle: bookmark.bookName,
                          lessonName: bookmark.chapterName,
                          lessonNumber: bookmark.chapterNumber,
                          chapterNumber: bookmark.pageStart,
                        ),
                        onDelete: () {
                          context.read<BookDetailsBloc>().add(
                            RemoveBookBookmark(bookmarkId: bookmark.id),
                          );
                        },
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        }
        
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
