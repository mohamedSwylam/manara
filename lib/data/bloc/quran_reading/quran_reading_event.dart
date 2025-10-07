import 'package:equatable/equatable.dart';

abstract class QuranReadingEvent extends Equatable {
  const QuranReadingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSurahData extends QuranReadingEvent {
  final int surahNumber;
  final String surahName;
  final int startAyah;

  const LoadSurahData({
    required this.surahNumber,
    required this.surahName,
    this.startAyah = 1,
  });

  @override
  List<Object?> get props => [surahNumber, surahName, startAyah];
}

class PlayAudio extends QuranReadingEvent {
  final String audioUrl;
  final int ayahIndex;

  const PlayAudio({
    required this.audioUrl,
    required this.ayahIndex,
  });

  @override
  List<Object?> get props => [audioUrl, ayahIndex];
}

class PauseAudio extends QuranReadingEvent {
  const PauseAudio();
}

class ToggleAyahExpansion extends QuranReadingEvent {
  final int ayahIndex;

  const ToggleAyahExpansion({required this.ayahIndex});

  @override
  List<Object?> get props => [ayahIndex];
}

class LoadTafsirData extends QuranReadingEvent {
  final int surahNumber;
  final int ayahNumber;

  const LoadTafsirData({
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  List<Object?> get props => [surahNumber, ayahNumber];
}

// New events for highlighting and scrolling
class HighlightAyah extends QuranReadingEvent {
  final int ayahIndex;

  const HighlightAyah({required this.ayahIndex});

  @override
  List<Object?> get props => [ayahIndex];
}

class ClearHighlight extends QuranReadingEvent {
  const ClearHighlight();
}

class HighlightBookmarkedAyah extends QuranReadingEvent {
  final int ayahNumber;

  const HighlightBookmarkedAyah({required this.ayahNumber});

  @override
  List<Object?> get props => [ayahNumber];
}

class ScrollToAyah extends QuranReadingEvent {
  final int ayahIndex;

  const ScrollToAyah({required this.ayahIndex});

  @override
  List<Object?> get props => [ayahIndex];
}

class ScrollToBookmarkedAyah extends QuranReadingEvent {
  final int ayahIndex;

  const ScrollToBookmarkedAyah({required this.ayahIndex});

  @override
  List<Object?> get props => [ayahIndex];
}

class ScrollToPosition extends QuranReadingEvent {
  final double scrollPosition;
  final int ayahIndex; // Add ayahIndex

  const ScrollToPosition({required this.scrollPosition, required this.ayahIndex});

  @override
  List<Object?> get props => [scrollPosition, ayahIndex];
}

// Popup menu action events
class HandlePopupMenuAction extends QuranReadingEvent {
  final String action;
  final int ayahIndex;
  final Map<String, dynamic> ayah;

  const HandlePopupMenuAction({
    required this.action,
    required this.ayahIndex,
    required this.ayah,
  });

  @override
  List<Object?> get props => [action, ayahIndex, ayah];
}

class ShareAyah extends QuranReadingEvent {
  final int ayahIndex;
  final Map<String, dynamic> ayah;

  const ShareAyah({
    required this.ayahIndex,
    required this.ayah,
  });

  @override
  List<Object?> get props => [ayahIndex, ayah];
}

class CopyAyah extends QuranReadingEvent {
  final int ayahIndex;
  final Map<String, dynamic> ayah;

  const CopyAyah({
    required this.ayahIndex,
    required this.ayah,
  });

  @override
  List<Object?> get props => [ayahIndex, ayah];
}

class SaveLastReadPosition extends QuranReadingEvent {
  final int ayahIndex;

  const SaveLastReadPosition({required this.ayahIndex});

  @override
  List<Object?> get props => [ayahIndex];
}
