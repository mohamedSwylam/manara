import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class QuranThemeState extends Equatable {
  const QuranThemeState();

  @override
  List<Object?> get props => [];
}

class QuranThemeInitial extends QuranThemeState {}

class QuranThemeLoaded extends QuranThemeState {
  final int selectedThemeIndex;
  final double quranFontSize;
  final double tafsirFontSize;
  final bool tajweedRules;
  final bool vibrationOnNewPage;
  final List<Map<String, dynamic>> themes;

  const QuranThemeLoaded({
    required this.selectedThemeIndex,
    required this.quranFontSize,
    required this.tafsirFontSize,
    required this.tajweedRules,
    required this.vibrationOnNewPage,
    required this.themes,
  });

  QuranThemeLoaded copyWith({
    int? selectedThemeIndex,
    double? quranFontSize,
    double? tafsirFontSize,
    bool? tajweedRules,
    bool? vibrationOnNewPage,
    List<Map<String, dynamic>>? themes,
  }) {
    return QuranThemeLoaded(
      selectedThemeIndex: selectedThemeIndex ?? this.selectedThemeIndex,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      tafsirFontSize: tafsirFontSize ?? this.tafsirFontSize,
      tajweedRules: tajweedRules ?? this.tajweedRules,
      vibrationOnNewPage: vibrationOnNewPage ?? this.vibrationOnNewPage,
      themes: themes ?? this.themes,
    );
  }

  Map<String, dynamic> get currentTheme => themes[selectedThemeIndex];
  
  Color get backgroundColor => currentTheme['bgColor'];
  Color get textColor => currentTheme['textColor'];
  Color get titleColor => currentTheme['titleColor'];
  String get themeName => currentTheme['name'];

  @override
  List<Object?> get props => [
        selectedThemeIndex,
        quranFontSize,
        tafsirFontSize,
        tajweedRules,
        vibrationOnNewPage,
        themes,
      ];
}

class QuranThemeError extends QuranThemeState {
  final String message;

  const QuranThemeError({required this.message});

  @override
  List<Object?> get props => [message];
}
