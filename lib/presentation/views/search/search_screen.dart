import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../constants/colors.dart';
import '../../../constants/images.dart';
import '../../../data/bloc/search/search_bloc.dart';
import '../../../data/bloc/search/search_event.dart';
import '../../../data/bloc/search/search_state.dart';
import '../quran/quran_reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _TextMatch {
  final int start;
  final int end;

  _TextMatch({required this.start, required this.end});
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Auto focus search field and load history after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      // Load search history after the widget is built
      context.read<SearchBloc>().add(const LoadSearchHistory());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F3F3),
      appBar: _buildAppBar(theme, isDark),
      body: Column(
        children: [
          _buildTabBar(theme, isDark),
                     Expanded(
             child: TabBarView(
               key: const ValueKey('search_tab_view'),
               controller: _tabController,
               children: [
                 _buildSearchContent('all'),
                 _buildSearchContent('quran'),
                 _buildSearchContent('tafsir'),
                 _buildSearchContent('others'),
               ],
             ),
           ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: theme.iconTheme.color,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: _buildSearchField(theme, isDark),
      titleSpacing: 0,
    );
  }

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF404040) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
                             onChanged: (value) {
                 final category = _getCategoryFromIndex(_tabController.index);
                 context.read<SearchBloc>().add(SearchQueryChanged(
                   query: value,
                   category: category,
                 ));
               },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<SearchBloc>().add(const ClearSearch());
              },
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F3F3),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.colorPrimary,
        indicatorWeight: 2,
        labelColor: AppColors.colorPrimary,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
                 onTap: (index) {
           final category = _getCategoryFromIndex(index);
           context.read<SearchBloc>().add(SearchCategoryChanged(category: category));
         },
        tabs: [
          Tab(text: 'all'.tr),
          Tab(text: 'quran'.tr),
          Tab(text: 'tafsir'.tr),
          Tab(text: 'others'.tr),
        ],
      ),
    );
  }

  Widget _buildSearchContent(String category) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is SearchError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
              ),
            ),
          );
        }

        if (state is SearchLoaded) {
          if (_searchController.text.isEmpty) {
            return _buildSearchHistory(state.searchHistory);
          }

          // Filter results based on current category
          final filteredResults = _filterResultsByCategory(state.categoryResults, category);
          return _buildSearchResults(filteredResults);
        }

        return _buildEmptyState();
      },
    );
  }

  List<SearchCategoryResult> _filterResultsByCategory(List<SearchCategoryResult> results, String category) {
    if (category == 'all') {
      return results;
    }
    
    return results.where((result) {
      switch (category) {
        case 'quran':
          return result.category == 'surahs' || result.category == 'quran_text';
        case 'tafsir':
          return result.category == 'tafsir';
        case 'others':
          return result.category == 'others';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildSearchHistory(List<String> history) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (history.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final query = history[index];
        return ListTile(
          leading: Icon(
            Icons.history,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          title: Text(
            query,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16.sp,
            ),
          ),
          onTap: () {
            _searchController.text = query;
            final category = _getCategoryFromIndex(_tabController.index);
            context.read<SearchBloc>().add(SearchQueryChanged(
              query: query,
              category: category,
            ));
          },
        );
      },
    );
  }

  Widget _buildSearchResults(List<SearchCategoryResult> results) {
    if (results.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      key: const ValueKey('search_results_list'),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final categoryResult = results[index];
        return Column(
          key: ValueKey('category_${categoryResult.category}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(categoryResult.title),
            ...categoryResult.results.map((result) => _buildSearchResultCard(result)),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 360.w,
      height: 30.h,
      color: isDark 
          ? const Color(0xFF2A2A2A).withOpacity(0.2)
          : const Color(0xFFD5CCA1).withOpacity(0.2),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentQuery = _searchController.text.toLowerCase().trim();

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Handle tap on search result
            if (result.type == 'surah') {
              // Navigate to surah reading screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranReadingScreen(
                    surahNumber: result.surahNumber!,
                    surahName: result.surahName!,
                  ),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            color: theme.cardTheme.color,
            child: Row(
              children: [
                // Surah number with book icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      AssetsPath.bookPartSVG,
                      width: 40.w,
                      height: 40.h,
                    ),
                    Text(
                      result.type == 'surah' ? '${result.surahNumber}' : '${result.ayahNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8D1B3D),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                // Surah details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // English name (if available and in English locale)
                                if (result.type == 'surah' && result.englishName != null && Get.locale?.languageCode == 'en')
                                  _buildHighlightedText(
                                    text: result.englishName!,
                                    query: currentQuery,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                                    ),
                                  ),
                                
                                // Arabic name
                                _buildHighlightedText(
                                  text: result.type == 'surah' ? result.subtitle : result.title,
                                  query: currentQuery,
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),
                      // Details row
                      Row(
                        children: [
                          if (result.type == 'surah') ...[
                            // Revelation type
                            Text(
                              result.content.split(' • ').last, // Get revelation type
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFA7805A)
                              ),
                            ),
                            
                            SizedBox(width: 8.w),
                            
                            // Number of ayahs
                            Text(
                              '- ${result.content.split(' verses • ').first} Ayahs',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFA7805A)
                              ),
                            ),
                            
                            SizedBox(width: 8.w),
                            
                            // Juz information (placeholder for now)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8D1B3D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Juz 1', // This would need to be calculated
                                style: GoogleFonts.poppins(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8D1B3D)
                                ),
                              ),
                            ),
                          ] else ...[
                            // For ayah results, show the ayah text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Arabic text
                                  _buildHighlightedText(
                                    text: result.subtitle,
                                    query: currentQuery,
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: theme.textTheme.titleMedium?.color ?? Colors.black87,
                                    ),
                                    maxLines: 2,
                                  ),
                                  SizedBox(height: 2.h),
                                  // Translation
                                  _buildHighlightedText(
                                    text: result.content,
                                    query: currentQuery,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFA7805A),
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Page number or ayah number
                Text(
                  result.type == 'surah' ? '1' : '${result.ayahNumber}', // Page would need to be calculated
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFF828282)
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Divider
        Divider(
          height: 1,
          thickness: 0.5,
          color: theme.dividerTheme.color ?? Colors.grey.shade200,
          indent: 68.w, // Align with content (40 + 12 + 16)
        ),
      ],
    );
  }

  Widget _buildHighlightedText({
    required String text,
    required String query,
    required TextStyle style,
    int? maxLines,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    final matches = <_TextMatch>[];

    // Find all matches in the text
    int startIndex = 0;
    while (startIndex < textLower.length) {
      final matchIndex = textLower.indexOf(queryLower, startIndex);
      if (matchIndex == -1) break;
      
      matches.add(_TextMatch(
        start: matchIndex,
        end: matchIndex + queryLower.length,
      ));
      startIndex = matchIndex + 1;
    }

    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    // Merge overlapping matches
    final mergedMatches = <_TextMatch>[];
    for (final match in matches) {
      if (mergedMatches.isEmpty) {
        mergedMatches.add(match);
      } else {
        final lastMatch = mergedMatches.last;
        if (match.start <= lastMatch.end) {
          // Overlapping or adjacent matches, merge them
          mergedMatches.last = _TextMatch(
            start: lastMatch.start,
            end: match.end > lastMatch.end ? match.end : lastMatch.end,
          );
        } else {
          mergedMatches.add(match);
        }
      }
    }

    // Build rich text with highlights
    final textSpans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in mergedMatches) {
      // Add text before match
      if (match.start > currentIndex) {
        textSpans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: style,
        ));
      }

      // Add highlighted match
      textSpans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: style.copyWith(
          color: const Color(0xFF8D1B3D), // Maroon color for highlights
          fontWeight: FontWeight.w700,
        ),
      ));

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      textSpans.add(TextSpan(
        text: text.substring(currentIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: textSpans),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64.sp,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'search_empty_title'.tr,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'search_empty_subtitle'.tr,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.sp,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'no_results_found'.tr,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'try_different_keywords'.tr,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getCategoryFromIndex(int index) {
    switch (index) {
      case 0:
        return 'all';
      case 1:
        return 'quran';
      case 2:
        return 'tafsir';
      case 3:
        return 'others';
      default:
        return 'all';
    }
  }
}
