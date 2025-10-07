import 'package:equatable/equatable.dart';

abstract class QuranThemeEvent extends Equatable {
  const QuranThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeSettings extends QuranThemeEvent {
  const LoadThemeSettings();
}

class SetThemeIndex extends QuranThemeEvent {
  final int index;

  const SetThemeIndex({required this.index});

  @override
  List<Object?> get props => [index];
}

class SetQuranFontSize extends QuranThemeEvent {
  final double size;

  const SetQuranFontSize({required this.size});

  @override
  List<Object?> get props => [size];
}

class SetTafsirFontSize extends QuranThemeEvent {
  final double size;

  const SetTafsirFontSize({required this.size});

  @override
  List<Object?> get props => [size];
}

class SetTajweedRules extends QuranThemeEvent {
  final bool value;

  const SetTajweedRules({required this.value});

  @override
  List<Object?> get props => [value];
}

class SetVibrationOnNewPage extends QuranThemeEvent {
  final bool value;

  const SetVibrationOnNewPage({required this.value});

  @override
  List<Object?> get props => [value];
}
