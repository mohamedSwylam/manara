import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../../constants/images.dart';
import '../../../data/models/prayer_times_model.dart';
import '../../../data/bloc/prayer_times_bloc.dart';
import '../../../data/models/prayer_times_events.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Events
abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends PrayerEvent {}

class UpdateTimer extends PrayerEvent {}

class NavigateToPreviousDay extends PrayerEvent {}

class NavigateToNextDay extends PrayerEvent {}

class ToggleNotification extends PrayerEvent {
  final int prayerIndex;

  const ToggleNotification(this.prayerIndex);

  @override
  List<Object?> get props => [prayerIndex];
}

class UpdateCurrentPrayer extends PrayerEvent {}

class LoadLocation extends PrayerEvent {
  final double latitude;
  final double longitude;

  const LoadLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class UpdatePrayerTimes extends PrayerEvent {
  final List<Map<String, dynamic>> prayers;
  final String locationName;

  const UpdatePrayerTimes(this.prayers, this.locationName);

  @override
  List<Object?> get props => [prayers, locationName];
}

class SelectDate extends PrayerEvent {
  final DateTime selectedDate;

  const SelectDate(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

// States
abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final Duration timeRemaining;
  final String currentPrayer;
  final DateTime selectedDate;
  final int currentPrayerIndex;
  final List<Map<String, dynamic>> prayers;
  final List<PrayerTimesModel> prayerTimes;
  final String locationName;

  const PrayerLoaded({
    required this.timeRemaining,
    required this.currentPrayer,
    required this.selectedDate,
    required this.currentPrayerIndex,
    required this.prayers,
    required this.prayerTimes,
    required this.locationName,
  });

  @override
  List<Object?> get props => [
        timeRemaining,
        currentPrayer,
        selectedDate,
        currentPrayerIndex,
        prayers,
        prayerTimes,
        locationName,
      ];

  PrayerLoaded copyWith({
    Duration? timeRemaining,
    String? currentPrayer,
    DateTime? selectedDate,
    int? currentPrayerIndex,
    List<Map<String, dynamic>>? prayers,
    List<PrayerTimesModel>? prayerTimes,
    String? locationName,
  }) {
    return PrayerLoaded(
      timeRemaining: timeRemaining ?? this.timeRemaining,
      currentPrayer: currentPrayer ?? this.currentPrayer,
      selectedDate: selectedDate ?? this.selectedDate,
      currentPrayerIndex: currentPrayerIndex ?? this.currentPrayerIndex,
      prayers: prayers ?? this.prayers,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      locationName: locationName ?? this.locationName,
    );
  }
}

class PrayerError extends PrayerState {
  final String message;

  const PrayerError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  Timer? _timer;

  PrayerBloc() : super(PrayerInitial()) {
    on<StartTimer>(_onStartTimer);
    on<UpdateTimer>(_onUpdateTimer);
    on<NavigateToPreviousDay>(_onNavigateToPreviousDay);
    on<NavigateToNextDay>(_onNavigateToNextDay);
    on<ToggleNotification>(_onToggleNotification);
    on<UpdateCurrentPrayer>(_onUpdateCurrentPrayer);
    on<LoadLocation>(_onLoadPrayerTimes);
    on<UpdatePrayerTimes>(_onUpdatePrayerTimes);
    on<SelectDate>(_onSelectDate);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onStartTimer(StartTimer event, Emitter<PrayerState> emit) {
    final prayers = _initializePrayers();
    emit(PrayerLoaded(
      timeRemaining: const Duration(minutes: 5, seconds: 27),
      currentPrayer: 'Asr',
      selectedDate: DateTime.now(),
      currentPrayerIndex: 3,
      prayers: prayers,
      prayerTimes: [],
      locationName: 'Doha, Qatar',
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateTimer());
    });
  }

  void _onLoadPrayerTimes(LoadLocation event, Emitter<PrayerState> emit) {
    // For now, we'll just emit the current state
    // In a real implementation, you would integrate with the PrayerTimesBloc
    // This can be done by listening to the PrayerTimesBloc state in the UI
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      emit(currentState.copyWith(
        locationName: 'Loading location...',
      ));
    }
  }

  void _onUpdatePrayerTimes(UpdatePrayerTimes event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      emit(currentState.copyWith(
        prayers: event.prayers,
        locationName: event.locationName,
        prayerTimes: currentState.prayerTimes,
      ));
    }
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      Duration newTimeRemaining = currentState.timeRemaining;

      if (newTimeRemaining.inSeconds > 0) {
        newTimeRemaining = newTimeRemaining - const Duration(seconds: 1);
      } else {
        newTimeRemaining = const Duration(minutes: 5, seconds: 27);
      }

      emit(currentState.copyWith(timeRemaining: newTimeRemaining));
    }
  }

  void _onNavigateToPreviousDay(NavigateToPreviousDay event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      final newDate = currentState.selectedDate.subtract(const Duration(days: 1));
      emit(currentState.copyWith(selectedDate: newDate));
    }
  }

  void _onNavigateToNextDay(NavigateToNextDay event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      final newDate = currentState.selectedDate.add(const Duration(days: 1));
      emit(currentState.copyWith(selectedDate: newDate));
    }
  }

  void _onToggleNotification(ToggleNotification event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      final updatedPrayers = List<Map<String, dynamic>>.from(currentState.prayers);
      final prayer = updatedPrayers[event.prayerIndex];
      String currentNotification = prayer['notification'];

      // Cycle through notification types: sound -> muted -> vibrate -> sound
      switch (currentNotification) {
        case 'sound':
          prayer['notification'] = 'muted';
          break;
        case 'muted':
          prayer['notification'] = 'vibrate';
          break;
        case 'vibrate':
          prayer['notification'] = 'sound';
          break;
      }

      emit(currentState.copyWith(prayers: updatedPrayers));
    }
  }

  void _onUpdateCurrentPrayer(UpdateCurrentPrayer event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      final now = DateTime.now();
      final currentTime = TimeOfDay.fromDateTime(now);

      // Find the current prayer based on time
      for (int i = 0; i < currentState.prayers.length; i++) {
        final prayer = currentState.prayers[i];
        final prayerTime = _parseTimeString(prayer['time']);

        if (currentTime.hour == prayerTime.hour && currentTime.minute == prayerTime.minute) {
          final updatedPrayers = List<Map<String, dynamic>>.from(currentState.prayers);
          
          // Reset all prayers to not current
          for (var p in updatedPrayers) {
            p['isCurrent'] = false;
          }

          // Set current prayer
          updatedPrayers[i]['isCurrent'] = true;

          emit(currentState.copyWith(
            currentPrayer: prayer['name'],
            currentPrayerIndex: i,
            prayers: updatedPrayers,
          ));
          break;
        }
      }
    }
  }

  void _onSelectDate(SelectDate event, Emitter<PrayerState> emit) {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      
      // Update the selected date
      emit(currentState.copyWith(selectedDate: event.selectedDate));
      
      // TODO: In a real implementation, you would fetch prayer times for the selected date
      // For now, we'll keep the same prayer times but update the current prayer logic
      // based on the selected date
      
      // You can add logic here to fetch prayer times for the selected date
      // by dispatching an event to PrayerTimesBloc
    }
  }

  List<Map<String, dynamic>> _initializePrayers() {
    return [
      {
        'name': 'Fajr',
        'icon': AssetsPath.fazr,
        'time': '04:27',
        'notification': 'sound', // sound, muted, vibrate
        'isCurrent': false,
      },
      {
        'name': 'Sunrise',
        'icon': AssetsPath.fazr,
        'time': '06:18',
        'notification': 'muted',
        'isCurrent': false,
      },
      {
        'name': 'Dhuhur',
        'icon': AssetsPath.duhr,
        'time': '13:33',
        'notification': 'vibrate',
        'isCurrent': false,
      },
      {
        'name': 'Asr',
        'icon': AssetsPath.asr,
        'time': '17:27',
        'notification': 'sound',
        'isCurrent': true,
      },
      {
        'name': 'Maghrib',
        'icon': AssetsPath.magrib,
        'time': '20:49',
        'notification': 'sound',
        'isCurrent': false,
      },
      {
        'name': 'Isha',
        'icon': AssetsPath.isha,
        'time': '22:33',
        'notification': 'sound',
        'isCurrent': false,
      },
    ];
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Helper methods for the UI
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String getHijriDate() {
    // In a real app, use hijri package to get actual Hijri date
    return '17 Rajab 1445H';
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Get background PNG based on current prayer
  String getCurrentPrayerBackground() {
    if (state is PrayerLoaded) {
      final currentState = state as PrayerLoaded;
      final currentPrayer = currentState.currentPrayer.toLowerCase();
      
      switch (currentPrayer) {
        case 'fajr':
          return AssetsPath.fajrPNG; // Using existing PNG as fallback
        case 'sunrise':
          return AssetsPath.shruokPNG; // Using existing PNG as fallback
        case 'dhuhur':
          return AssetsPath.dhuhurPNG; // Using existing PNG as fallback
        case 'asr':
          return AssetsPath.asrPNG; // Using existing PNG as fallback
        case 'maghrib':
          return AssetsPath.magribPNG; // Using existing PNG as fallback
        case 'isha':
          return AssetsPath.ishaPNG; // Using existing PNG as fallback
        default:
          return AssetsPath.duaBackgroundPNG; // Default fallback
      }
    }
    return AssetsPath.duaBackgroundPNG; // Default fallback
  }

  Widget getNotificationIcon(String type) {
    switch (type) {
      case 'sound':
        return SvgPicture.asset(
          AssetsPath.soundSVG,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.green,
            BlendMode.srcIn,
          ),
        );
      case 'muted':
        return SvgPicture.asset(
          AssetsPath.nosoundSVG,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.red,
            BlendMode.srcIn,
          ),
        );
      case 'vibrate':
        return SvgPicture.asset(
          AssetsPath.vibrationSVG,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.srcIn,
          ),
        );
      default:
        return SvgPicture.asset(
          AssetsPath.soundSVG,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Colors.green,
            BlendMode.srcIn,
          ),
        );
    }
  }
} 
