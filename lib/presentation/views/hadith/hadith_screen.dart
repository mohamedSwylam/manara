import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../data/bloc/hadith/hadith_bloc.dart';
import '../../../data/bloc/hadith/hadith_event.dart';
import '../../../data/bloc/hadith/hadith_state.dart';
import 'widgets/hadith_book_card.dart';
import 'widgets/hadith_collection_card.dart';
import 'widgets/bookmark_item.dart';
import 'widgets/search_bar_widget.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HadithBloc()..add(LoadHadithBooks()),
      child: const HadithView(),
    );
  }
}

class HadithView extends StatefulWidget {
  const HadithView({super.key});

  @override
  State<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends State<HadithView> with TickerProviderStateMixin {
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
          'hadith'.tr,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios, 
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<HadithBloc, HadithState>(
        builder: (context, state) {
          if (state is HadithLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.textTheme.bodyMedium?.color,
              ),
            );
          } else if (state is HadithError) {
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
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HadithBloc>().add(LoadHadithBooks());
                    },
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            );
          } else if (state is HadithLoaded) {
            return Column(
              children: [
                // Book Cards Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: HadithBookCard(
                          book: state.books.isNotEmpty ? state.books[0] : null,
                          isLeftCard: true,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: HadithBookCard(
                          book: state.books.length > 1 ? state.books[1] : null,
                          isLeftCard: false,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab Bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF8D1B3D),
                  labelColor: theme.textTheme.titleMedium?.color,
                  unselectedLabelColor: theme.textTheme.bodySmall?.color,
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
                    Tab(text: 'hadith'.tr),
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
                      // Hadith Collection Page
                      _buildHadithCollectionPage(context, state),
                      
                      // Bookmarks Page
                      _buildBookmarksPage(context, state),
                    ],
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHadithCollectionPage(BuildContext context, HadithLoaded state) {
    if (state.collection.isEmpty) {
      context.read<HadithBloc>().add(LoadHadithCollection());
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 12.h,),
          // Search Bar
          SearchBarWidget(
            onSearch: (query) {
              context.read<HadithBloc>().add(SearchHadith(query: query));
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Hadith Collection List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.collection.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: HadithCollectionCard(
                  hadith: state.collection[index],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksPage(BuildContext context, HadithLoaded state) {
    final theme = Theme.of(context);
    if (state.bookmarks.isEmpty) {
      context.read<HadithBloc>().add(LoadBookmarks());
    }
    
    // Group bookmarks by book title
    final Map<String, List<Bookmark>> groupedBookmarks = {};
    for (final bookmark in state.bookmarks) {
      if (!groupedBookmarks.containsKey(bookmark.bookTitle)) {
        groupedBookmarks[bookmark.bookTitle] = [];
      }
      groupedBookmarks[bookmark.bookTitle]!.add(bookmark);
    }
    
    return SingleChildScrollView(
      child: Column(
        children: groupedBookmarks.entries.map((entry) {
          final bookTitle = entry.key;
          final bookmarks = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Title Container
              Container(
                width: double.infinity,
                height: 30.h,
                padding: EdgeInsets.only(top: 3, left: 16.w, right: 16.w),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color?.withOpacity(0.3) ?? const Color(0x1BFFFF83),
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
              
              // Bookmarks List
              ...bookmarks.map((bookmark) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: BookmarkItem(
                  bookmark: bookmark,
                  onDelete: () {
                    context.read<HadithBloc>().add(
                      RemoveBookmark(bookmarkId: bookmark.id),
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
}
