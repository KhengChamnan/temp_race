import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/race_result_board_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

/// Provider for handling race result board data and operations
/// Implements caching to avoid unnecessary refreshes
class RaceResultBoardProvider extends ChangeNotifier {
  final RaceResultBoardRepository _raceResultBoardRepository;
  
  // AsyncValue to track the state of current race result board
  AsyncValue<RaceResultBoard>? currentRaceResultBoard;
  
  // Cached race result board data to prevent unnecessary refreshes
  RaceResultBoard? _cachedRaceResultBoard;
  bool _hasLoadedInitialData = false;
  
  // Stream subscription for real-time race result board updates
  StreamSubscription<RaceResultBoard>? _raceResultBoardSubscription;
  
  RaceResultBoardProvider({required RaceResultBoardRepository raceResultBoardRepository})
      : _raceResultBoardRepository = raceResultBoardRepository {
    // Initialize by subscribing to real-time race result board updates
    _subscribeToRaceResultBoardUpdates();
  }
  
  @override
  void dispose() {
    // Cancel the stream subscription when the provider is disposed
    _raceResultBoardSubscription?.cancel();
    super.dispose();
  }

  /// Subscribe to real-time race result board updates from repository
  void _subscribeToRaceResultBoardUpdates() {
    // Cancel any existing subscription
    _raceResultBoardSubscription?.cancel();
    
    // If we haven't loaded data yet, show loading state
    if (!_hasLoadedInitialData) {
      currentRaceResultBoard = const AsyncValue.loading();
      notifyListeners();
    }
    
    // Subscribe to the race result board stream
    _raceResultBoardSubscription = _raceResultBoardRepository.getRaceResultBoardStream().listen(
      (board) {
        // Update cache and state with the latest race result board data
        _cachedRaceResultBoard = board;
        _hasLoadedInitialData = true;
        currentRaceResultBoard = AsyncValue.success(board);
        notifyListeners();
      },
      onError: (error) {
        // If we have cached data, use it on error
        if (_hasLoadedInitialData && _cachedRaceResultBoard != null) {
          currentRaceResultBoard = AsyncValue.success(_cachedRaceResultBoard!);
        } else {
          currentRaceResultBoard = AsyncValue.error(error);
        }
        notifyListeners();
        
        // Retry subscription after error with a delay
        Future.delayed(const Duration(seconds: 5), _subscribeToRaceResultBoardUpdates);
      }
    );
  }

  /// Fetch the current race result board from the repository
  /// Used as a fallback or for initial data fetching if needed
  Future<void> fetchCurrentRaceResultBoard() async {
    // If we're already loading, don't start another fetch
    if (currentRaceResultBoard?.isLoading == true) return;
    
    // If we've already loaded data, don't show loading indicator again
    if (!_hasLoadedInitialData) {
      currentRaceResultBoard = const AsyncValue.loading();
      notifyListeners();
    }

    try {
      // Fetch the data
      final board = await _raceResultBoardRepository.getCurrentRaceResultBoard();
      
      // Update cache and state
      _cachedRaceResultBoard = board;
      _hasLoadedInitialData = true;
      currentRaceResultBoard = AsyncValue.success(board);
      notifyListeners();
    } catch (error) {
      // If we have cached data, use it on error
      if (_hasLoadedInitialData && _cachedRaceResultBoard != null) {
        currentRaceResultBoard = AsyncValue.success(_cachedRaceResultBoard!);
      } else {
        currentRaceResultBoard = AsyncValue.error(error);
      }
      notifyListeners();
    }
  }

  /// Get results for a specific race
  Future<RaceResultBoard> getRaceResultBoardByRace(Race race) async {
    try {
      return await _raceResultBoardRepository.getRaceResultBoardByRace(race);
    } catch (error) {
      // If we have cached data for the current race and it matches the requested race,
      // return it as a fallback
      if (_hasLoadedInitialData && 
          _cachedRaceResultBoard != null && 
          _cachedRaceResultBoard!.race.date == race.date) {
        return _cachedRaceResultBoard!;
      }
      rethrow;
    }
  }

  /// Generate and save a race result board
  Future<void> generateRaceResultBoard(Race race) async {
    try {
      // Show loading state
      currentRaceResultBoard = const AsyncValue.loading();
      notifyListeners();
      
      // Generate the board
      final board = await _raceResultBoardRepository.generateRaceResultBoard(race);
      
      // Update cache and state
      _cachedRaceResultBoard = board;
      _hasLoadedInitialData = true;
      currentRaceResultBoard = AsyncValue.success(board);
      notifyListeners();
    } catch (error) {
      // If we have cached data, use it on error
      if (_hasLoadedInitialData && _cachedRaceResultBoard != null) {
        currentRaceResultBoard = AsyncValue.success(_cachedRaceResultBoard!);
      } else {
        currentRaceResultBoard = AsyncValue.error(error);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Get race result item for a specific participant
  Future<RaceResultItem?> getResultItemByParticipant(String bibNumber, Race race) async {
    try {
      return await _raceResultBoardRepository.getResultItemByParticipant(bibNumber, race);
    } catch (error) {
      // If we have cached data, try to find the participant in it
      if (_hasLoadedInitialData && 
          _cachedRaceResultBoard != null &&
          _cachedRaceResultBoard!.race.date == race.date) {
        try {
          return _cachedRaceResultBoard!.resultItems.firstWhere(
            (item) => item.bibNumber == bibNumber
          );
        } catch (_) {
          return null;
        }
      }
      rethrow;
    }
  }

  /// Export race results to a file format (e.g., CSV, PDF)
  Future<String> exportRaceResults(Race race, String format) async {
    return await _raceResultBoardRepository.exportRaceResults(race, format);
  }
} 