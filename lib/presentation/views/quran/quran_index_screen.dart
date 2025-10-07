import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../data/bloc/quran/quran_bloc.dart';
import '../../../data/bloc/quran/quran_event.dart';
import '../../../data/bloc/quran/quran_state.dart';
import '../../../data/bloc/bookmark/bookmark_bloc.dart';
import '../../../data/bloc/bookmark/bookmark_event.dart' as bookmark_event;
import '../../../data/bloc/bookmark/bookmark_state.dart';
import '../../../data/models/quran/quran_ayah_bookmark_model.dart';
import '../../../data/services/quran_api_service.dart';
import '../menus/quran_settings_screen.dart';
import 'quran_reading_screen.dart';
import 'widgets/quran_card.dart';
import 'widgets/quran_search_bar.dart';
import 'widgets/quran_surah_item.dart';
import 'widgets/quran_juz_expansion_tile.dart';
import 'widgets/quran_bookmark_item.dart';
import 'widgets/quran_ayah_bookmark_item.dart';
import 'package:flutter/widgets.dart';

class QuranIndexScreen extends StatelessWidget {
  final bool hideBackButton;
  
  const QuranIndexScreen({super.key, this.hideBackButton = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuranBloc>(
          create: (context) => QuranBloc()..add(const LoadQuranData()),
        ),
        BlocProvider<BookmarkBloc>(
          create: (context) => BookmarkBloc()..add(bookmark_event.LoadBookmarks()),
        ),
      ],
      child: QuranIndexView(hideBackButton: hideBackButton),
    );
  }
}

class QuranIndexView extends StatefulWidget {
  final bool hideBackButton;
  
  const QuranIndexView({super.key, this.hideBackButton = false});

  @override
  State<QuranIndexView> createState() => _QuranIndexViewState();
}

class _QuranIndexViewState extends State<QuranIndexView> with TickerProviderStateMixin, WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late PageController _pageController;
  bool _isTabChanging = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    
    // Load bookmarks immediately when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookmarkBloc>().add(bookmark_event.LoadBookmarks());
      }
    });
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging && !_isTabChanging) {
        _isTabChanging = true;
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ).then((_) {
          _isTabChanging = false;
        });
      }
      
      // Refresh bookmarks when Bookmarks tab is selected
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        context.read<BookmarkBloc>().add(bookmark_event.LoadBookmarks());
      }
    });
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh both Quran data and bookmarks when app is resumed
      _refreshData();
    }
  }

  void _refreshData() {
    if (mounted) {
      context.read<QuranBloc>().add(const LoadQuranData());
      context.read<BookmarkBloc>().add(bookmark_event.LoadBookmarks());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'quran_index'.tr,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        leading: widget.hideBackButton ? null : IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is QuranError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64.sp,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'offline_mode'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'showing_cached_data'.tr + '\n${state.message}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color ?? Colors.black54,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<QuranBloc>().add(const LoadQuranData());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text('refresh'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D1B3D),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is QuranLoaded) {
            return Column(
              children: [
                // Last Read and Last Bookmark Cards
                BlocBuilder<BookmarkBloc, BookmarkState>(
                  builder: (context, bookmarkState) {
                                                              // Check if we have last read data
                     final hasLastRead = state.lastReadSurah != null && 
                                       state.lastReadSurah!.isNotEmpty && 
                                       state.lastReadPage != null && 
                                       state.lastReadPage! > 0;
                     
                     // Check if we have bookmark data
                     final hasBookmarks = bookmarkState is BookmarkLoaded && 
                                        bookmarkState.bookmarks.isNotEmpty;
                     

                    
                    // Only show cards if we have data
                    if (!hasLastRead && !hasBookmarks) {
                      return const SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          // Last Read Card (only show if we have last read data)
                          if (hasLastRead) ...[
                            Expanded(
                              child: QuranCard(
                                title: state.lastReadSurah!,
                                subtitle: '${'page'.tr} ${state.lastReadPage} - ${'juz'.tr} ${state.lastReadJuz}',
                                status: 'last_read'.tr,
                                isLeftCard: true,
                              ),
                            ),
                            if (hasBookmarks) SizedBox(width: 12.w),
                          ],
                          
                          // Last Bookmark Card (only show if we have bookmark data)
                          if (hasBookmarks) ...[
                            Expanded(
                              child: QuranCard(
                                title: bookmarkState.bookmarks.first.surahName,
                                subtitle: bookmarkState.bookmarks.first.type == BookmarkType.ayah 
                                    ? '${'ayah'.tr} ${bookmarkState.bookmarks.first.ayahNumber} - ${'page'.tr} ${bookmarkState.bookmarks.first.pageNumber}'
                                    : '${'page'.tr} ${bookmarkState.bookmarks.first.pageNumber} - ${'juz'.tr} ${bookmarkState.bookmarks.first.juzNumber}',
                                status: 'last_bookmark'.tr,
                                isLeftCard: false,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                
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
                    Tab(text: 'sura'.tr),
                    Tab(text: 'juz'.tr),
                    Tab(text: 'bookmarks'.tr),
                  ],
                ),
                
                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                                          onPageChanged: (index) {
                        if (!_isTabChanging) {
                          _isTabChanging = true;
                          _tabController.animateTo(index);
                          // Reset the flag after animation completes
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _isTabChanging = false;
                          });
                        }
                        
                        // Refresh bookmarks when swiping to Bookmarks tab
                        if (index == 2) {
                          context.read<BookmarkBloc>().add(bookmark_event.LoadBookmarks());
                        }
                      },
                    children: [
                      // Sura Page
                      _buildSuraPage(context, state),
                      
                      // Juz Page
                      _buildJuzPage(context, state),
                      
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

  Widget _buildSuraPage(BuildContext context, QuranLoaded state) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: QuranSearchBar(
            onSearch: (query) {
              context.read<QuranBloc>().add(SearchQuran(query: query));
            },
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Surah List grouped by Juz with Pagination
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<QuranBloc>().add(const LoadQuranData());
            },
            child: SingleChildScrollView(
              child: _buildSurahListByJuz(state.filteredSurahs),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurahListByJuz(List<QuranSurah> surahs) {
    // Cache the grouped surahs to avoid rebuilding on every build
    return _SurahListByJuzWidget(
      surahs: surahs,
      onSurahTap: () => _refreshData(),
    );
  }

  Widget _buildJuzPage(BuildContext context, QuranLoaded state) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: QuranSearchBar(
            onSearch: (query) {
              // Implement juz search if needed
            },
          ),
        ),
        SizedBox(height: 16.h),
        // Juz List with Pagination
        Expanded(
          child: ListView.builder(
            itemCount: state.juzs.length,
            itemBuilder: (context, index) {
              return QuranJuzCard(
                juz: state.juzs[index],
                onTap: () {
                  // Navigate to juz details
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarksPage(BuildContext context, QuranLoaded state) {
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, bookmarkState) {
        if (bookmarkState is BookmarkLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (bookmarkState is BookmarkLoaded) {
          final bookmarks = bookmarkState.bookmarks;
          
          if (bookmarks.isEmpty) {
            return Column(
              children: [
                SizedBox(height: 12.h),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'no_bookmarks_yet'.tr,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          
          return Column(
            children: [
              SizedBox(height: 12.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<BookmarkBloc>().add(bookmark_event.LoadBookmarks());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = bookmarks[index];
                      return QuranAyahBookmarkItem(
                        bookmark: bookmark,
                        onDelete: () {
                          context.read<BookmarkBloc>().add(
                            bookmark_event.RemoveBookmark(bookmarkId: bookmark.id),
                          );
                        },
                        onTap: () {
                          // Navigate to the bookmarked surah/ayah
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuranReadingScreen(
                                surahName: bookmark.surahName,
                                surahNumber: bookmark.surahNumber,
                                highlightAyah: bookmark.type == BookmarkType.ayah 
                                    ? bookmark.ayahNumber 
                                    : null, // Only highlight if it's an ayah bookmark
                              ),
                            ),
                          ).then((_) {
                            // Refresh bookmarks when returning from Quran Reading screen
                            context.read<BookmarkBloc>().add(bookmark_event.LoadBookmarks());
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        
        return Center(
          child: Text('error_loading_bookmarks'.tr),
        );
      },
    );
  }
}

// Separate widget to cache the surah grouping logic
class _SurahListByJuzWidget extends StatelessWidget {
  final List<QuranSurah> surahs;
  final VoidCallback onSurahTap;
  
  const _SurahListByJuzWidget({
    required this.surahs,
    required this.onSurahTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create a more accurate juz mapping based on Quran structure
    final Map<int, List<QuranSurah>> groupedSurahs = {};
    
    // Initialize all 30 juz
    for (int i = 1; i <= 30; i++) {
      groupedSurahs[i] = [];
    }
    
    // Create a map of surah numbers to their actual juz appearances
    final Map<int, List<int>> surahJuzMapping = {
      1: [1], // Al-Fatiha
      2: [1, 2, 3], // Al-Baqarah
      3: [3, 4], // Aal-Imran - FIXED: only in Juz 3, 4
      4: [4, 5, 6], // An-Nisa
      5: [6, 7], // Al-Ma'idah
      6: [7, 8], // Al-An'am
      7: [8, 9], // Al-A'raf
      8: [9, 10], // Al-Anfal
      9: [10, 11], // At-Tawbah
      10: [11], // Yunus
      11: [11, 12], // Hud
      12: [12, 13], // Yusuf
      13: [13], // Ar-Ra'd
      14: [13], // Ibrahim
      15: [14], // Al-Hijr
      16: [14, 15], // An-Nahl
      17: [15, 16], // Al-Isra
      18: [15, 16], // Al-Kahf
      19: [16], // Maryam
      20: [16], // Ta-Ha
      21: [17], // Al-Anbya
      22: [17], // Al-Hajj
      23: [18], // Al-Mu'minun
      24: [18], // An-Nur
      25: [19], // Al-Furqan
      26: [19], // Ash-Shu'ara
      27: [19, 20], // An-Naml
      28: [20], // Al-Qasas
      29: [20, 21], // Al-Ankabut
      30: [21], // Ar-Rum
      31: [21], // Luqman
      32: [21], // As-Sajdah
      33: [21, 22], // Al-Ahzab
      34: [22], // Saba
      35: [22], // Fatir
      36: [22, 23], // Ya-Sin
      37: [23], // As-Saffat
      38: [23], // Sad
      39: [23, 24], // Az-Zumar
      40: [24, 25], // Ghafir
      41: [25], // Fussilat
      42: [25], // Ash-Shuraa
      43: [25], // Az-Zukhruf
      44: [25], // Ad-Dukhan
      45: [25], // Al-Jathiyah
      46: [26], // Al-Ahqaf
      47: [26], // Muhammad
      48: [26], // Al-Fath
      49: [26], // Al-Hujurat
      50: [26], // Qaf
      51: [26, 27], // Adh-Dhariyat
      52: [27], // At-Tur
      53: [27], // An-Najm
      54: [27], // Al-Qamar
      55: [27], // Ar-Rahman
      56: [27], // Al-Waqi'ah
      57: [27], // Al-Hadid
      58: [28], // Al-Mujadila
      59: [28], // Al-Hashr
      60: [28], // Al-Mumtahanah
      61: [28], // As-Saf
      62: [28], // Al-Jumu'ah
      63: [28], // Al-Munafiqun
      64: [28], // At-Taghabun
      65: [28], // At-Talaq
      66: [28], // At-Tahrim
      67: [29], // Al-Mulk
      68: [29], // Al-Qalam
      69: [29], // Al-Haqqah
      70: [29], // Al-Ma'arij
      71: [29], // Nuh
      72: [29], // Al-Jinn
      73: [29], // Al-Muzzammil
      74: [29], // Al-Muddathir
      75: [29], // Al-Qiyamah
      76: [29], // Al-Insan
      77: [29], // Al-Mursalat
      78: [30], // An-Naba
      79: [30], // An-Nazi'at
      80: [30], // Abasa
      81: [30], // At-Takwir
      82: [30], // Al-Infitar
      83: [30], // Al-Mutaffifin
      84: [30], // Al-Inshiqaq
      85: [30], // Al-Buruj
      86: [30], // At-Tariq
      87: [30], // Al-A'la
      88: [30], // Al-Ghashiyah
      89: [30], // Al-Fajr
      90: [30], // Al-Balad
      91: [30], // Ash-Shams
      92: [30], // Al-Layl
      93: [30], // Ad-Duha
      94: [30], // Ash-Sharh
      95: [30], // At-Tin
      96: [30], // Al-Alaq
      97: [30], // Al-Qadr
      98: [30], // Al-Bayyinah
      99: [30], // Az-Zalzalah
      100: [30], // Al-Adiyat
      101: [30], // Al-Qari'ah
      102: [30], // At-Takathur
      103: [30], // Al-Asr
      104: [30], // Al-Humazah
      105: [30], // Al-Fil
      106: [30], // Quraysh
      107: [30], // Al-Ma'un
      108: [30], // Al-Kawthar
      109: [30], // Al-Kafirun
      110: [30], // An-Nasr
      111: [30], // Al-Masad
      112: [30], // Al-Ikhlas
      113: [30], // Al-Falaq
      114: [30], // An-Nas
    };
    
    // Group surahs by their correct juz appearances
    for (final surah in surahs) {
      final correctJuzs = surahJuzMapping[surah.number] ?? [surah.juz];
      for (final juzNumber in correctJuzs) {
        if (groupedSurahs.containsKey(juzNumber)) {
          // Check if this surah is already added to this juz
          final existingSurah = groupedSurahs[juzNumber]!.where((s) => s.number == surah.number).firstOrNull;
          if (existingSurah == null) {
            groupedSurahs[juzNumber]!.add(surah);
          }
        }
      }
    }
    
    // Sort surahs within each juz by their page number
    for (final juzSurahs in groupedSurahs.values) {
      juzSurahs.sort((a, b) => a.page.compareTo(b.page));
    }

    return Column(
      children: groupedSurahs.entries.where((entry) => entry.value.isNotEmpty).map((entry) {
        final juzNumber = entry.key;
        final juzSurahs = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Juz Header
            Container(
              color: const Color(0x66FFFFFF),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Juz\' ${juzNumber.toString()}',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8D1B3D),
                      ),
                    ),
                    Text(
                      '${juzSurahs.first.page}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Surahs in this Juz
            ...juzSurahs.map((surah) => QuranSurahItem(
              surah: surah,
                                       onTap: () {
                           // Navigate to Quran reading screen
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => QuranReadingScreen(
                                 surahName: surah.name,
                                 surahNumber: surah.number,
                               ),
                             ),
                           ).then((_) {
                             // Refresh data when returning from Quran reading
                             onSurahTap();
                           });
                         },
            )),
          ],
        );
      }).toList(),
    );
  }
}
