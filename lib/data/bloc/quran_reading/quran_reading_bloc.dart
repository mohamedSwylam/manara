import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/last_read_service.dart';
import 'quran_reading_event.dart';
import 'quran_reading_state.dart';

class QuranReadingBloc extends Bloc<QuranReadingEvent, QuranReadingState> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  QuranReadingBloc() : super(QuranReadingInitial()) {
    on<LoadSurahData>(_onLoadSurahData);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<ToggleAyahExpansion>(_onToggleAyahExpansion);
    on<LoadTafsirData>(_onLoadTafsirData);
    
    // New event handlers
    on<HighlightAyah>(_onHighlightAyah);
    on<ClearHighlight>(_onClearHighlight);
    on<HighlightBookmarkedAyah>(_onHighlightBookmarkedAyah);
    on<ScrollToAyah>(_onScrollToAyah);
    on<ScrollToBookmarkedAyah>(_onScrollToBookmarkedAyah);
    on<ScrollToPosition>(_onScrollToPosition);
    on<HandlePopupMenuAction>(_onHandlePopupMenuAction);
    on<ShareAyah>(_onShareAyah);
    on<CopyAyah>(_onCopyAyah);
    on<SaveLastReadPosition>(_onSaveLastReadPosition);

    // Initialize audio player
    _audioPlayer.onPlayerComplete.listen((event) {
      if (state is QuranReadingLoaded) {
        final currentState = state as QuranReadingLoaded;
        if (currentState.currentAyahIndex < currentState.audioUrls.length - 1) {
          add(PlayAudio(
            audioUrl: currentState.audioUrls[currentState.currentAyahIndex + 1],
            ayahIndex: currentState.currentAyahIndex + 1,
          ));
        } else {
          add(const PauseAudio());
        }
      }
    });
  }

  Future<void> _onLoadSurahData(
    LoadSurahData event,
    Emitter<QuranReadingState> emit,
  ) async {
    emit(QuranReadingLoading());

    try {
      // Fetch surah data from API (Arabic text)
      final arabicResponse = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/${event.surahNumber}'),
      );

      // Fetch English translation
      final translationResponse = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/${event.surahNumber}/en.sahih'),
      );

      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);
        
        final arabicAyahs = arabicData['data']['ayahs'] as List;
        final translationAyahs = translationData['data']['ayahs'] as List;
        
        final ayahs = arabicAyahs.asMap().entries.map((entry) {
          final index = entry.key;
          final arabicAyah = entry.value;
          final translationAyah = index < translationAyahs.length ? translationAyahs[index] : null;
          
          // Get the global ayah number for audio URL construction
          final globalAyahNumber = arabicAyah['number'];
          
          // Construct audio URL using the global ayah number
          String audioUrl = '';
          if (globalAyahNumber != null) {
            audioUrl = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalAyahNumber.mp3';
          }
          
          return {
            'number': arabicAyah['numberInSurah'],
            'text': arabicAyah['text'],
            'translation': translationAyah?['text'] ?? 'Translation not available',
            'audio': audioUrl,
            'page': arabicAyah['page'],
            'juz': arabicAyah['juz'],
            'ruku': arabicAyah['ruku'],
            'manzil': arabicAyah['manzil'],
          };
        }).toList();

        final audioUrls = ayahs.map((ayah) => ayah['audio'] as String).toList();

        // Save last read data with actual page information from the first ayah
        if (ayahs.isNotEmpty) {
          final firstAyah = ayahs.first;
          final pageNumber = int.tryParse(firstAyah['page'].toString()) ?? 1;
          final juzNumber = int.tryParse(firstAyah['juz'].toString()) ?? 1;
          final ayahNumber = int.tryParse(firstAyah['number'].toString()) ?? 1;
          
          print('DEBUG: Saving last read data:');
          print('  Surah: ${event.surahNumber} - ${event.surahName}');
          print('  Page: $pageNumber');
          print('  Juz: $juzNumber');
          print('  Ayah: $ayahNumber');
          print('  Raw first ayah data: $firstAyah');
          
          await LastReadService.saveLastRead(
            surahNumber: event.surahNumber,
            surahName: event.surahName,
            pageNumber: pageNumber,
            juzNumber: juzNumber,
            ayahNumber: ayahNumber,
          );
        }

        emit(QuranReadingLoaded(
          ayahs: ayahs,
          audioUrls: audioUrls,
          currentAyahIndex: 0,
          isAudioPlaying: false,
          surahName: event.surahName,
          surahNumber: event.surahNumber,
          expandedAyahs: const <int>{},
          tafsirData: const <String, String>{},
        ));

        // If startAyah is specified and different from 1, scroll to that ayah
        if (event.startAyah > 1 && event.startAyah <= ayahs.length) {
          // Convert ayah number (1-based) to index (0-based)
          final ayahIndex = event.startAyah - 1;
          
          // Add a small delay to ensure the UI is built before scrolling
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (!isClosed) {
            add(ScrollToAyah(ayahIndex: ayahIndex));
          }
        }
      } else {
        emit(QuranReadingError(
          message: 'Failed to load surah data: ${arabicResponse.statusCode}',
          surahName: event.surahName,
          surahNumber: event.surahNumber,
        ));
      }
    } catch (e) {
      emit(QuranReadingError(
        message: 'Error loading surah data: $e',
        surahName: event.surahName,
        surahNumber: event.surahNumber,
      ));
    }
  }

  Future<void> _onPlayAudio(
    PlayAudio event,
    Emitter<QuranReadingState> emit,
  ) async {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      try {
        await _audioPlayer.play(UrlSource(event.audioUrl));
        
        emit(currentState.copyWith(
          currentAyahIndex: event.ayahIndex,
          isAudioPlaying: true,
        ));
      } catch (e) {
        emit(QuranReadingError(
          message: 'Error playing audio: $e',
          surahName: currentState.surahName,
          surahNumber: currentState.surahNumber,
        ));
      }
    }
  }

  Future<void> _onPauseAudio(
    PauseAudio event,
    Emitter<QuranReadingState> emit,
  ) async {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      try {
        await _audioPlayer.pause();
        
        emit(currentState.copyWith(
          isAudioPlaying: false,
        ));
      } catch (e) {
        emit(QuranReadingError(
          message: 'Error pausing audio: $e',
          surahName: currentState.surahName,
          surahNumber: currentState.surahNumber,
        ));
      }
    }
  }

  void _onToggleAyahExpansion(
    ToggleAyahExpansion event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      final newExpandedAyahs = Set<int>.from(currentState.expandedAyahs);
      
      if (newExpandedAyahs.contains(event.ayahIndex)) {
        newExpandedAyahs.remove(event.ayahIndex);
      } else {
        newExpandedAyahs.add(event.ayahIndex);
      }
      
      emit(currentState.copyWith(
        expandedAyahs: newExpandedAyahs,
      ));
    }
  }

  Future<void> _onLoadTafsirData(
    LoadTafsirData event,
    Emitter<QuranReadingState> emit,
  ) async {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      final tafsirKey = '${event.surahNumber}:${event.ayahNumber}';
      
      // Check if tafsir is already loaded
      if (currentState.tafsirData.containsKey(tafsirKey)) {
        return;
      }
      
      try {
        // Simulate tafsir loading - replace with actual API call
        await Future.delayed(const Duration(milliseconds: 500));
        
        final newTafsirData = Map<String, String>.from(currentState.tafsirData);
        newTafsirData[tafsirKey] = 'This is the tafsir (interpretation) for Ayah ${event.ayahNumber} of Surah ${event.surahNumber}.';
        
        emit(currentState.copyWith(
          tafsirData: newTafsirData,
        ));
      } catch (e) {
        // Handle tafsir loading error silently
        print('Error loading tafsir: $e');
      }
    }
  }

  // New event handlers
  void _onHighlightAyah(
    HighlightAyah event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      emit(currentState.copyWith(
        highlightedAyahIndex: event.ayahIndex,
        isHighlightAnimationActive: false, // No animation for regular taps
      ));
      
      // Clear highlight after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed && state is QuranReadingLoaded && 
            (state as QuranReadingLoaded).highlightedAyahIndex == event.ayahIndex) {
          add(const ClearHighlight());
        }
      });
    }
  }

  void _onClearHighlight(
    ClearHighlight event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      emit(currentState.copyWith(
        highlightedAyahIndex: null,
        isHighlightAnimationActive: false,
      ));
    }
  }

  void _onHighlightBookmarkedAyah(
    HighlightBookmarkedAyah event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      print('DEBUG: Looking for ayah number: ${event.ayahNumber}');
      print('DEBUG: Available ayah numbers: ${currentState.ayahs.map((ayah) => ayah['number']).toList()}');
      
      // Find the ayah index by ayah number
      final ayahIndex = currentState.ayahs.indexWhere(
        (ayah) => ayah['number'] == event.ayahNumber,
      );
      
      print('DEBUG: Found ayah at index: $ayahIndex');
      
      if (ayahIndex != -1) {
        print('DEBUG: Emitting highlight and scroll for ayah index: $ayahIndex');
        emit(currentState.copyWith(
          highlightedAyahIndex: ayahIndex,
          isHighlightAnimationActive: true,
          shouldScrollToAyah: true,
          scrollToAyahIndex: ayahIndex,
        ));
        
        // Clear highlight after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (!isClosed && state is QuranReadingLoaded && 
              (state as QuranReadingLoaded).highlightedAyahIndex == ayahIndex) {
            add(const ClearHighlight());
          }
        });
      } else {
        print('DEBUG: Ayah number ${event.ayahNumber} not found in surah');
      }
    }
  }

  void _onScrollToAyah(
    ScrollToAyah event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      emit(currentState.copyWith(
        shouldScrollToAyah: true,
        scrollToAyahIndex: event.ayahIndex,
      ));
    }
  }

  void _onScrollToBookmarkedAyah(
    ScrollToBookmarkedAyah event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      emit(currentState.copyWith(
        shouldScrollToAyah: true,
        scrollToAyahIndex: event.ayahIndex,
      ));
    }
  }

  void _onScrollToPosition(
    ScrollToPosition event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      emit(currentState.copyWith(
        shouldScrollToPosition: true,
        scrollToPosition: event.scrollPosition,
        highlightedAyahIndex: event.ayahIndex, // Add highlight
        isHighlightAnimationActive: true, // Activate animation
      ));

      // Clear highlight after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!isClosed && state is QuranReadingLoaded &&
            (state as QuranReadingLoaded).highlightedAyahIndex == event.ayahIndex) {
          add(const ClearHighlight());
        }
      });
    }
  }

  void _onHandlePopupMenuAction(
    HandlePopupMenuAction event,
    Emitter<QuranReadingState> emit,
  ) {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      // Clear highlight when any action is performed
      emit(currentState.copyWith(
        highlightedAyahIndex: null,
        popupMenuAction: event.action,
      ));
      
      switch (event.action) {
        case 'play':
          if (currentState.isAudioPlaying) {
            add(const PauseAudio());
          } else {
            add(PlayAudio(
              audioUrl: currentState.audioUrls[event.ayahIndex],
              ayahIndex: event.ayahIndex,
            ));
          }
          break;
        case 'share':
          add(ShareAyah(
            ayahIndex: event.ayahIndex,
            ayah: event.ayah,
          ));
          break;
        case 'copy':
          add(CopyAyah(
            ayahIndex: event.ayahIndex,
            ayah: event.ayah,
          ));
          break;
        case 'save':
          // This will be handled by the BookmarkBloc
          emit(currentState.copyWith(
            toastMessage: 'Ayah bookmarked',
            toastIconPath: 'assets/images/save.png',
          ));
          break;
        case 'tafsir':
          add(ToggleAyahExpansion(ayahIndex: event.ayahIndex));
          
          // Load tafsir if not already loaded
          final tafsirKey = '${currentState.surahNumber}:${event.ayah['number']}';
          final tafsirText = currentState.tafsirData[tafsirKey];
          if (tafsirText == null) {
            add(LoadTafsirData(
              surahNumber: currentState.surahNumber,
              ayahNumber: event.ayah['number'],
            ));
          }
          break;
      }
    }
  }

  Future<void> _onShareAyah(
    ShareAyah event,
    Emitter<QuranReadingState> emit,
  ) async {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      final shareText = '''
Surah ${currentState.surahName} - Ayah ${event.ayah['number']}

${event.ayah['text']}

Translation:
${event.ayah['translation']}

Shared from Manara App
''';

      try {
        await Share.share(
          shareText,
          subject: 'Surah ${currentState.surahName} - Ayah ${event.ayah['number']}',
        );
      } catch (e) {
        // Fallback to clipboard if share fails
        await Clipboard.setData(ClipboardData(text: shareText));
        emit(currentState.copyWith(
          toastMessage: 'Ayah copied to clipboard for sharing',
          toastIconPath: 'assets/images/share.svg',
        ));
      }
    }
  }

  Future<void> _onCopyAyah(
    CopyAyah event,
    Emitter<QuranReadingState> emit,
  ) async {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      final copyText = '''
Surah ${currentState.surahName} - Ayah ${event.ayah['number']}

${event.ayah['text']}

Translation:
${event.ayah['translation']}
''';

      await Clipboard.setData(ClipboardData(text: copyText));
      emit(currentState.copyWith(
        toastMessage: 'Ayah copied to clipboard',
        toastIconPath: 'assets/images/content_copy.svg',
      ));
    }
  }

  Future<void> _onSaveLastReadPosition(
    SaveLastReadPosition event,
    Emitter<QuranReadingState> emit,
  ) async {
    if (state is QuranReadingLoaded) {
      final currentState = state as QuranReadingLoaded;
      
      if (event.ayahIndex < currentState.ayahs.length) {
        final ayah = currentState.ayahs[event.ayahIndex];
        final pageNumber = int.tryParse(ayah['page'].toString()) ?? 1;
        final juzNumber = int.tryParse(ayah['juz'].toString()) ?? 1;
        final ayahNumber = int.tryParse(ayah['number'].toString()) ?? 1;
        
        print('DEBUG: Saving last read position:');
        print('  Ayah index: ${event.ayahIndex}');
        print('  Page: $pageNumber');
        print('  Juz: $juzNumber');
        print('  Ayah: $ayahNumber');
        
        await LastReadService.saveLastRead(
          surahNumber: currentState.surahNumber,
          surahName: currentState.surahName,
          pageNumber: pageNumber,
          juzNumber: juzNumber,
          ayahNumber: ayahNumber,
        );
      }
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
