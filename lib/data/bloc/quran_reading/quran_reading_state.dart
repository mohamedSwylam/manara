import 'package:equatable/equatable.dart';

abstract class QuranReadingState extends Equatable {
  const QuranReadingState();

  @override
  List<Object?> get props => [];
}

class QuranReadingInitial extends QuranReadingState {}

class QuranReadingLoading extends QuranReadingState {}

class QuranReadingLoaded extends QuranReadingState {
  final List<Map<String, dynamic>> ayahs;
  final List<String> audioUrls;
  final int currentAyahIndex;
  final bool isAudioPlaying;
  final String surahName;
  final int surahNumber;
  final Set<int> expandedAyahs;
  final Map<String, String> tafsirData;
  
  // New state properties for highlighting and scrolling
  final int? highlightedAyahIndex;
  final bool isHighlightAnimationActive;
  final bool shouldScrollToAyah;
  final int? scrollToAyahIndex;
  final bool shouldScrollToPosition;
  final double? scrollToPosition;
  final String? popupMenuAction;
  final String? toastMessage;
  final String? toastIconPath;

  const QuranReadingLoaded({
    required this.ayahs,
    required this.audioUrls,
    required this.currentAyahIndex,
    required this.isAudioPlaying,
    required this.surahName,
    required this.surahNumber,
    required this.expandedAyahs,
    required this.tafsirData,
    this.highlightedAyahIndex,
    this.isHighlightAnimationActive = false,
    this.shouldScrollToAyah = false,
    this.scrollToAyahIndex,
    this.shouldScrollToPosition = false,
    this.scrollToPosition,
    this.popupMenuAction,
    this.toastMessage,
    this.toastIconPath,
  });

  QuranReadingLoaded copyWith({
    List<Map<String, dynamic>>? ayahs,
    List<String>? audioUrls,
    int? currentAyahIndex,
    bool? isAudioPlaying,
    String? surahName,
    int? surahNumber,
    Set<int>? expandedAyahs,
    Map<String, String>? tafsirData,
    int? highlightedAyahIndex,
    bool? isHighlightAnimationActive,
    bool? shouldScrollToAyah,
    int? scrollToAyahIndex,
    bool? shouldScrollToPosition,
    double? scrollToPosition,
    String? popupMenuAction,
    String? toastMessage,
    String? toastIconPath,
  }) {
    return QuranReadingLoaded(
      ayahs: ayahs ?? this.ayahs,
      audioUrls: audioUrls ?? this.audioUrls,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      surahName: surahName ?? this.surahName,
      surahNumber: surahNumber ?? this.surahNumber,
      expandedAyahs: expandedAyahs ?? this.expandedAyahs,
      tafsirData: tafsirData ?? this.tafsirData,
      highlightedAyahIndex: highlightedAyahIndex,
      isHighlightAnimationActive: isHighlightAnimationActive ?? this.isHighlightAnimationActive,
      shouldScrollToAyah: shouldScrollToAyah ?? this.shouldScrollToAyah,
      scrollToAyahIndex: scrollToAyahIndex,
      shouldScrollToPosition: shouldScrollToPosition ?? this.shouldScrollToPosition,
      scrollToPosition: scrollToPosition,
      popupMenuAction: popupMenuAction,
      toastMessage: toastMessage,
      toastIconPath: toastIconPath,
    );
  }

  @override
  List<Object?> get props => [
        ayahs,
        audioUrls,
        currentAyahIndex,
        isAudioPlaying,
        surahName,
        surahNumber,
        expandedAyahs,
        tafsirData,
        highlightedAyahIndex,
        isHighlightAnimationActive,
        shouldScrollToAyah,
        scrollToAyahIndex,
        popupMenuAction,
        toastMessage,
        toastIconPath,
      ];
}

class QuranReadingError extends QuranReadingState {
  final String message;
  final String surahName;
  final int surahNumber;

  const QuranReadingError({
    required this.message,
    required this.surahName,
    required this.surahNumber,
  });

  @override
  List<Object?> get props => [message, surahName, surahNumber];
}
