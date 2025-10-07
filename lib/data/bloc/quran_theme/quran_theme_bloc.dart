import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quran_theme_event.dart';
import 'quran_theme_state.dart';

class QuranThemeBloc extends Bloc<QuranThemeEvent, QuranThemeState> {
  QuranThemeBloc() : super(QuranThemeInitial()) {
    on<LoadThemeSettings>(_onLoadThemeSettings);
    on<SetThemeIndex>(_onSetThemeIndex);
    on<SetQuranFontSize>(_onSetQuranFontSize);
    on<SetTafsirFontSize>(_onSetTafsirFontSize);
    on<SetTajweedRules>(_onSetTajweedRules);
    on<SetVibrationOnNewPage>(_onSetVibrationOnNewPage);
  }

  final List<Map<String, dynamic>> _themes = [
    {
      'name': 'Beige', 
      'bgColor': const Color(0xFFF5F5DC), 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA6A7805A), 
      'selected': true
    },
    {
      'name': 'White', 
      'bgColor': Colors.white, 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA6000000), 
      'selected': false
    },
    {
      'name': 'Dark', 
      'bgColor': Colors.black, 
      'textColor': Colors.white, 
      'titleColor': const Color(0xFFA7805A), 
      'selected': false
    },
    {
      'name': 'Green', 
      'bgColor': const Color(0xFFE8F5E8), 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA65AA774), 
      'selected': false
    },
    {
      'name': 'Warm', 
      'bgColor': const Color(0xFFF7F4E7), 
      'textColor': Colors.black, 
      'titleColor': const Color(0xA6A7805A), 
      'selected': false
    },
  ];

  Future<void> _onLoadThemeSettings(
    LoadThemeSettings event,
    Emitter<QuranThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedThemeIndex = prefs.getInt('quran_theme_index') ?? 0;
      final quranFontSize = prefs.getDouble('quran_font_size') ?? 18.0;
      final tafsirFontSize = prefs.getDouble('tafsir_font_size') ?? 19.0;
      final tajweedRules = prefs.getBool('tajweed_rules') ?? true;
      final vibrationOnNewPage = prefs.getBool('vibration_on_new_page') ?? true;

      emit(QuranThemeLoaded(
        selectedThemeIndex: selectedThemeIndex,
        quranFontSize: quranFontSize,
        tafsirFontSize: tafsirFontSize,
        tajweedRules: tajweedRules,
        vibrationOnNewPage: vibrationOnNewPage,
        themes: _themes,
      ));
    } catch (e) {
      emit(QuranThemeError(message: 'Error loading theme settings: $e'));
    }
  }

  Future<void> _onSetThemeIndex(
    SetThemeIndex event,
    Emitter<QuranThemeState> emit,
  ) async {
    if (state is QuranThemeLoaded) {
      final currentState = state as QuranThemeLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('quran_theme_index', event.index);
        
        emit(currentState.copyWith(selectedThemeIndex: event.index));
      } catch (e) {
        emit(QuranThemeError(message: 'Error saving theme index: $e'));
      }
    }
  }

  Future<void> _onSetQuranFontSize(
    SetQuranFontSize event,
    Emitter<QuranThemeState> emit,
  ) async {
    if (state is QuranThemeLoaded) {
      final currentState = state as QuranThemeLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('quran_font_size', event.size);
        
        emit(currentState.copyWith(quranFontSize: event.size));
      } catch (e) {
        emit(QuranThemeError(message: 'Error saving Quran font size: $e'));
      }
    }
  }

  Future<void> _onSetTafsirFontSize(
    SetTafsirFontSize event,
    Emitter<QuranThemeState> emit,
  ) async {
    if (state is QuranThemeLoaded) {
      final currentState = state as QuranThemeLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('tafsir_font_size', event.size);
        
        emit(currentState.copyWith(tafsirFontSize: event.size));
      } catch (e) {
        emit(QuranThemeError(message: 'Error saving Tafsir font size: $e'));
      }
    }
  }

  Future<void> _onSetTajweedRules(
    SetTajweedRules event,
    Emitter<QuranThemeState> emit,
  ) async {
    if (state is QuranThemeLoaded) {
      final currentState = state as QuranThemeLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('tajweed_rules', event.value);
        
        emit(currentState.copyWith(tajweedRules: event.value));
      } catch (e) {
        emit(QuranThemeError(message: 'Error saving Tajweed rules: $e'));
      }
    }
  }

  Future<void> _onSetVibrationOnNewPage(
    SetVibrationOnNewPage event,
    Emitter<QuranThemeState> emit,
  ) async {
    if (state is QuranThemeLoaded) {
      final currentState = state as QuranThemeLoaded;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('vibration_on_new_page', event.value);
        
        emit(currentState.copyWith(vibrationOnNewPage: event.value));
      } catch (e) {
        emit(QuranThemeError(message: 'Error saving vibration setting: $e'));
      }
    }
  }
}
