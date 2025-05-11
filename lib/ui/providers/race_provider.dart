import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

/// Provider for handling race data and operations
/// Implements caching to avoid unnecessary refreshes
class RaceProvider extends ChangeNotifier {
  final RaceRepository _raceRepository;
  
  // AsyncValue to track the state of current race
  AsyncValue<Race>? currentRace;
  
  // Cached race data to prevent unnecessary refreshes
  Race? _cachedRace;
  bool _hasLoadedInitialData = false;
  
  // Stream subscription for real-time race updates
  StreamSubscription<Race>? _raceSubscription;
  
  RaceProvider({required RaceRepository raceRepository})
      : _raceRepository = raceRepository {
    // Initialize by subscribing to real-time race updates
    _subscribeToRaceUpdates();
  }
  
  @override
  void dispose() {
    // Cancel the stream subscription when the provider is disposed
    _raceSubscription?.cancel();
    super.dispose();
  }

  /// Subscribe to real-time race updates from repository
  void _subscribeToRaceUpdates() {
    // Cancel any existing subscription
    _raceSubscription?.cancel();
    
    // If we haven't loaded data yet, show loading state
    if (!_hasLoadedInitialData) {
      currentRace = const AsyncValue.loading();
      notifyListeners();
    }
    
    // Subscribe to the race stream
    _raceSubscription = _raceRepository.getRaceStream().listen(
      (race) {
        // Update cache and state with the latest race data
        _cachedRace = race;
        _hasLoadedInitialData = true;
        currentRace = AsyncValue.success(race);
        notifyListeners();
      },
      onError: (error) {
        // If we have cached data, use it on error
        if (_hasLoadedInitialData && _cachedRace != null) {
          currentRace = AsyncValue.success(_cachedRace!);
        } else {
          currentRace = AsyncValue.error(error);
        }
        notifyListeners();
        
        // Retry subscription after error with a delay
        Future.delayed(const Duration(seconds: 5), _subscribeToRaceUpdates);
      }
    );
  }

  /// Fetch the current race from the repository
  /// Used as a fallback or for initial data fetching if needed
  Future<void> fetchCurrentRace() async {
    // If we're already loading, don't start another fetch
    if (currentRace?.isLoading == true) return;
    
    // If we've already loaded data, don't show loading indicator again
    if (!_hasLoadedInitialData) {
      currentRace = const AsyncValue.loading();
      notifyListeners();
    }

    try {
      // Fetch the data
      final race = await _raceRepository.getCurrentRace();
      
      // Update cache and state
      _cachedRace = race;
      _hasLoadedInitialData = true;
      currentRace = AsyncValue.success(race);
      notifyListeners();
    } catch (error) {
      // If we have cached data, use it on error
      if (_hasLoadedInitialData && _cachedRace != null) {
        currentRace = AsyncValue.success(_cachedRace!);
      } else {
        currentRace = AsyncValue.error(error);
      }
      notifyListeners();
    }
  }

  /// Start the race with optimistic updates
  Future<void> startRace() async {
    if (!_hasLoadedInitialData || _cachedRace == null) {
      await fetchCurrentRace();
      return;
    }

    try {
      // Optimistic UI update
      final updatedRace = _cachedRace!.copyWith(
        startTime: DateTime.now(),
        status: RaceStatus.started,
      );
      _cachedRace = updatedRace;
      currentRace = AsyncValue.success(updatedRace);
      notifyListeners();
      
      // Perform the actual update
      await _raceRepository.startRace();
      
      // No need to refresh in background as we're already subscribed to updates
    } catch (error) {
      // Roll back the optimistic update
      if (_cachedRace != null) {
        // Restore the original state using the latest data from stream
        currentRace = AsyncValue.success(_cachedRace!);
        notifyListeners();
      } else {
        currentRace = AsyncValue.error(error);
        notifyListeners();
      }
      
      // Rethrow the error so it can be handled in the UI
      rethrow;
    }
  }

  /// Finish the race with optimistic updates
  Future<void> finishRace() async {
    if (!_hasLoadedInitialData || _cachedRace == null) {
      await fetchCurrentRace();
      return;
    }

    try {
      // Optimistic UI update
      final updatedRace = _cachedRace!.copyWith(
        endTime: DateTime.now(),
        status: RaceStatus.finished,
      );
      _cachedRace = updatedRace;
      currentRace = AsyncValue.success(updatedRace);
      notifyListeners();
      
      // Perform the actual update
      await _raceRepository.finishRace();
      
      // No need to refresh in background as we're already subscribed to updates
    } catch (error) {
      // Handle errors - revert to previous state if needed
      if (_cachedRace != null) {
        // Restore the original state using the latest data from stream
        currentRace = AsyncValue.success(_cachedRace!);
        notifyListeners();
      } else {
        currentRace = AsyncValue.error(error);
        notifyListeners();
      }
    }
  }

  /// Reset the race with optimistic updates
  Future<void> resetRace() async {
    if (!_hasLoadedInitialData) {
      await fetchCurrentRace();
      return;
    }

    try {
      // For reset, we need participants from cached race
      final participantBibNumbers = _cachedRace?.participantBibNumbers ?? [];
      
      // Optimistic UI update with a fresh race
      final updatedRace = Race(
        date: DateTime.now(),
        status: RaceStatus.notStarted,
        startTime: null,
        endTime: null,
        participantBibNumbers: participantBibNumbers,
      );
      _cachedRace = updatedRace;
      currentRace = AsyncValue.success(updatedRace);
      notifyListeners();
      
      // Perform the actual update
      await _raceRepository.resetRace();
      
      // No need to refresh in background as we're already subscribed to updates
    } catch (error) {
      // Handle errors - revert to previous state if needed
      if (_cachedRace != null) {
        // Restore the original state if possible
        currentRace = AsyncValue.success(_cachedRace!);
        notifyListeners();
      } else {
        currentRace = AsyncValue.error(error);
        notifyListeners();
      }
    }
  }
  
  // Method kept for compatibility but not actively used
  // since we're now using real-time streaming
  Future<void> _refreshInBackground() async {
    try {
      final race = await _raceRepository.getCurrentRace();
      _cachedRace = race;
      currentRace = AsyncValue.success(race);
      notifyListeners();
    } catch (error) {
      // Silently fail - we already have optimistic updates
      // Only log the error in development
      if (kDebugMode) {
        print('Background refresh failed: $error');
      }
    }
  }
}
