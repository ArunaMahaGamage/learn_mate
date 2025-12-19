import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Define the state for the stopwatch with total seconds and running state
class StopwatchState {
  final int totalSeconds;  // Store total time in seconds for countdown
  final bool isRunning;

  StopwatchState({required this.totalSeconds, required this.isRunning});

  // Copy constructor for immutability
  StopwatchState copyWith({int? totalSeconds, bool? isRunning}) {
    return StopwatchState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  // Convert total seconds into hours, minutes, and seconds
  String get formattedTime {
    int hours = totalSeconds ~/ 3600; // Hours
    int minutes = (totalSeconds % 3600) ~/ 60; // Minutes
    int seconds = totalSeconds % 60; // Seconds

    return '${_twoDigitFormat(hours)}:${_twoDigitFormat(minutes)}:${_twoDigitFormat(seconds)}';
  }

  // Helper function to ensure two-digit format (e.g., "01" instead of "1")
  String _twoDigitFormat(int value) {
    return value.toString().padLeft(2, '0');
  }
}

// Create a notifier for managing the stopwatch state
class StopwatchNotifier extends StateNotifier<StopwatchState> {
  StopwatchNotifier() : super(StopwatchState(totalSeconds: 0, isRunning: false));

  late Timer _timer;

  // Start/Stop the stopwatch
  void toggleStopwatch() {
    if (state.isRunning) {
      _stopTimer();
      state = state.copyWith(isRunning: false);
    } else {
      _startTimer();
      state = state.copyWith(isRunning: true);
    }
  }

  // Update the time each second for stopwatch
  void _updateTime(Timer timer) {
    if (state.isRunning) {
      state = state.copyWith(totalSeconds: state.totalSeconds + 1);
    }
  }

  // Start the stopwatch timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  // Stop the stopwatch timer
  void _stopTimer() {
    _timer.cancel();
  }

  // Reset the stopwatch
  void resetStopwatch() {
    _stopTimer();
    state = state.copyWith(totalSeconds: 0, isRunning: false);
  }

  // Start Countdown from the given seconds
  void startCountdown(int totalSeconds) {
    _stopTimer();  // Stop any existing timers
    state = state.copyWith(totalSeconds: totalSeconds, isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.totalSeconds > 0) {
        state = state.copyWith(totalSeconds: state.totalSeconds - 1);
      } else {
        _stopTimer();  // Stop the timer when countdown reaches 0
      }
    });
  }

  // Stop countdown and reset
  void stopCountdown() {
    _stopTimer();
    state = state.copyWith(isRunning: false);
  }

  // Convert H:M:S format into total seconds for countdown
  int convertToSeconds(String time) {
    final parts = time.split(':');
    if (parts.length != 3) return 0;

    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;
    int seconds = int.tryParse(parts[2]) ?? 0;

    return (hours * 3600) + (minutes * 60) + seconds;
  }
}

// Define the provider for the stopwatch
final stopwatchProvider = StateNotifierProvider<StopwatchNotifier, StopwatchState>((ref) {
  return StopwatchNotifier();
});
