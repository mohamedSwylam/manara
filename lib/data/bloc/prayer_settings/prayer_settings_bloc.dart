import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

import '../../services/workmanager_notification_service.dart';

part 'prayer_settings_event.dart';
part 'prayer_settings_state.dart';

class PrayerSettingsBloc extends Bloc<PrayerSettingsEvent, PrayerSettingsState> {
  final WorkManagerNotificationService _notificationService = WorkManagerNotificationService();

  PrayerSettingsBloc() : super(PrayerSettingsInitial()) {
    on<LoadPrayerSettings>(_onLoadPrayerSettings);
    on<ToggleNotifications>(_onToggleNotifications);
    on<UpdateLocation>(_onUpdateLocation);
    on<SelectAdhanSound>(_onSelectAdhanSound);
    on<AddCustomRingtone>(_onAddCustomRingtone);
    on<DeleteCustomRingtone>(_onDeleteCustomRingtone);
    on<DismissNotificationBanner>(_onDismissNotificationBanner);
  }

  Future<void> _onLoadPrayerSettings(
    LoadPrayerSettings event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    emit(PrayerSettingsLoading());
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      String selectedLocation = prefs.getString('selected_location') ?? '';
      final selectedAdhanSound = prefs.getString('selected_adhan_sound') ?? 'Athan';
      final customRingtoneName = prefs.getString('custom_ringtone_name');
      final customRingtones = customRingtoneName != null ? <String>[customRingtoneName] : <String>[];
      final showNotificationBanner = prefs.getBool('show_notification_banner') ?? true;
      
      // If no location is saved, get current location
      if (selectedLocation.isEmpty) {
        try {
          selectedLocation = await _getCurrentLocationName();
          // Save the current location for future use
          await prefs.setString('selected_location', selectedLocation);
          await prefs.setDouble('selected_latitude', 25.2854); // Default coordinates
          await prefs.setDouble('selected_longitude', 51.5310);
        } catch (e) {
          selectedLocation = 'Doha, Qatar';
          await prefs.setString('selected_location', selectedLocation);
          await prefs.setDouble('selected_latitude', 25.2854);
          await prefs.setDouble('selected_longitude', 51.5310);
        }
      }
      
      emit(PrayerSettingsLoaded(
        notificationsEnabled: notificationsEnabled,
        selectedLocation: selectedLocation,
        selectedAdhanSound: selectedAdhanSound,
        customRingtones: customRingtones,
        showNotificationBanner: showNotificationBanner,
      ));
    } catch (e) {
      emit(PrayerSettingsError('Failed to load prayer settings: $e'));
    }
  }

  Future<String> _getCurrentLocationName() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Doha, Qatar';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Doha, Qatar';
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Get location name using geocoding
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        String locationString = "${placemark.locality}, ${placemark.country}";
        locationString = locationString.replaceAll('null, ', '').replaceAll(', null', '');
        
        // Save coordinates for future use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('selected_latitude', position.latitude);
        await prefs.setDouble('selected_longitude', position.longitude);
        
        return locationString.isNotEmpty ? locationString : 'Doha, Qatar';
      }

      return 'Doha, Qatar';
    } catch (e) {
      return 'Doha, Qatar';
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', event.enabled);
      
      // Update notification service
      await _notificationService.enableNotifications(event.enabled);
      
      if (state is PrayerSettingsLoaded) {
        final currentState = state as PrayerSettingsLoaded;
        emit(currentState.copyWith(notificationsEnabled: event.enabled));
      }
    } catch (e) {
      emit(PrayerSettingsError('Failed to update notifications: $e'));
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_location', event.location);
      
      // Also save to prayer location for consistency
      await prefs.setString('prayer_location', event.location);
      
      if (state is PrayerSettingsLoaded) {
        final currentState = state as PrayerSettingsLoaded;
        emit(currentState.copyWith(selectedLocation: event.location));
      }
    } catch (e) {
      emit(PrayerSettingsError('Failed to update location: $e'));
    }
  }

  Future<void> _onSelectAdhanSound(
    SelectAdhanSound event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_adhan_sound', event.soundName);
      
      // Update notification service to reschedule with new sound
      await _notificationService.updateNotificationSettings();
      
      if (state is PrayerSettingsLoaded) {
        final currentState = state as PrayerSettingsLoaded;
        emit(currentState.copyWith(selectedAdhanSound: event.soundName));
      }
    } catch (e) {
      emit(PrayerSettingsError('Failed to select adhan sound: $e'));
    }
  }

  Future<void> _onAddCustomRingtone(
    AddCustomRingtone event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store only one custom ringtone (replace existing)
      await prefs.setString('custom_ringtone_name', event.ringtoneName);
      await prefs.setString('custom_ringtone_path', event.filePath ?? '');
      
      if (state is PrayerSettingsLoaded) {
        final currentState = state as PrayerSettingsLoaded;
        emit(currentState.copyWith(customRingtones: [event.ringtoneName]));
      }
    } catch (e) {
      emit(PrayerSettingsError('Failed to add custom ringtone: $e'));
    }
  }

  Future<void> _onDeleteCustomRingtone(
    DeleteCustomRingtone event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the file path to delete the actual file
      final filePath = prefs.getString('custom_ringtone_path');
      if (filePath != null && filePath.isNotEmpty) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting file: $e');
        }
      }
      
      // Remove from preferences
      await prefs.remove('custom_ringtone_name');
      await prefs.remove('custom_ringtone_path');
      
      if (state is PrayerSettingsLoaded) {
        final currentState = state as PrayerSettingsLoaded;
        emit(currentState.copyWith(customRingtones: []));
      }
    } catch (e) {
      emit(PrayerSettingsError('Failed to delete custom ringtone: $e'));
    }
  }

  Future<void> _onDismissNotificationBanner(
    DismissNotificationBanner event,
    Emitter<PrayerSettingsState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_notification_banner', false);
      
      if (state is PrayerSettingsLoaded) {
        final currentState = state as PrayerSettingsLoaded;
        emit(currentState.copyWith(showNotificationBanner: false));
      }
    } catch (e) {
      emit(PrayerSettingsError('Failed to dismiss banner: $e'));
    }
  }
}
