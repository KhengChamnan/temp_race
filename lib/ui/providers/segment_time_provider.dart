import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

/// Provider for handling segment time operations
/// Implements caching to avoid unnecessary refreshes
class SegmentTimeProvider extends ChangeNotifier {
  final SegmentTimeRepository _repository;
  
  // AsyncValue to track the state of segment times
  AsyncValue<List<SegmentTime>> segmentTimesValue = const AsyncValue.loading();
  
  // Local cache of segment times for optimistic updates
  List<SegmentTime> _cachedSegmentTimes = [];
  bool _hasLoadedInitialData = false;
  
  // Stream subscription for segment times
  dynamic _segmentTimesSubscription;
  
  SegmentTimeProvider({required SegmentTimeRepository repository})
      : _repository = repository {
    // Initialize by subscribing to segment times stream
    subscribeToSegmentTimes();
  }
  
  void subscribeToSegmentTimes() {
    // First fetch initial data
    fetchSegmentTimes();
    
    _segmentTimesSubscription = _repository.getSegmentTimesStream().listen(
      (segmentTimes) {
        _cachedSegmentTimes = segmentTimes;
        _hasLoadedInitialData = true;
        segmentTimesValue = AsyncValue.success(segmentTimes);
        notifyListeners();
      },
      onError: (error) {
        if (_hasLoadedInitialData) {
          // If we have cached data, use it on error
          segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
        } else {
          segmentTimesValue = AsyncValue.error(error);
        }
        notifyListeners();
      }
    );
  }
  
  /// Start timing a segment for a participant
  Future<void> startSegmentTime(String bibNumber, String segmentName) async {
    try {
      // Optimistic update
      final newSegmentTime = SegmentTime(
        participantBibNumber: bibNumber,
        segmentName: segmentName,
        startTime: DateTime.now(),
      );
      
      _cachedSegmentTimes = List.from(_cachedSegmentTimes)
        ..removeWhere((time) => 
            time.participantBibNumber == bibNumber && 
            time.segmentName == segmentName &&
            time.endTime != null)
        ..add(newSegmentTime);
      
      segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      notifyListeners();
      
      // Perform actual update
      await _repository.startSegmentTime(bibNumber, segmentName);
    } catch (error) {
      // Revert optimistic update on error
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  /// End timing a segment for a participant
  Future<void> endSegmentTime(String bibNumber, String segmentName) async {
    final normalizedSegmentName = segmentName.toLowerCase();
    final isSwimSegment = normalizedSegmentName == 'swim';
    final segmentOrder = ['swim', 'cycle', 'run'];
    final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    try {
      // Find existing segment time
      final existingIndex = _cachedSegmentTimes.indexWhere(
        (time) => time.participantBibNumber == bibNumber && 
                 time.segmentName == normalizedSegmentName &&
                 time.endTime == null
      );
      
      final now = DateTime.now();
      
      if (existingIndex != -1) {
        // Found existing segment time - update it with end time
        final existingTime = _cachedSegmentTimes[existingIndex];
        final updatedTime = existingTime.copyWith(
          endTime: now,
        );
        
        // Update the segment in our cache
        _cachedSegmentTimes = List.from(_cachedSegmentTimes)
          ..[existingIndex] = updatedTime;
        
        segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
        notifyListeners();
      } else if (isSwimSegment) {
        // Special case for swim - create new entry with race start time
        // For optimistic UI update, use an approximate time
        
        DateTime? raceStartTime;
        
        // Try to find any existing swim segment to get race start time
        final existingSwimSegments = _cachedSegmentTimes.where(
          (time) => time.segmentName == 'swim' && time.startTime != null
        );
        
        if (existingSwimSegments.isNotEmpty) {
          raceStartTime = existingSwimSegments.first.startTime;
        } else {
          // Fallback to a reasonable time before now
          raceStartTime = now.subtract(const Duration(minutes: 1));
        }
        
        // Create new segment time with race start time and current end time
        final swimSegmentTime = SegmentTime(
          participantBibNumber: bibNumber,
          segmentName: 'swim',
          startTime: raceStartTime,
          endTime: now,
        );
        
        // Add swim segment to cache
        _cachedSegmentTimes = List.from(_cachedSegmentTimes)..add(swimSegmentTime);
        
        segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
        notifyListeners();
      } else {
        // For non-swim segments, check if previous segment exists and is complete
        if (segmentIndex > 0) {
          final previousSegmentName = segmentOrder[segmentIndex - 1];
          
          // Find previous segment
          final previousSegmentList = _cachedSegmentTimes.where(
            (time) => time.participantBibNumber == bibNumber && 
                     time.segmentName == previousSegmentName &&
                     time.endTime != null
          ).toList();
          
          final previousSegment = previousSegmentList.isNotEmpty ? previousSegmentList.first : null;
          
          if (previousSegment != null) {
            // Create new segment with start time from previous segment's end time
            final segmentTime = SegmentTime(
              participantBibNumber: bibNumber,
              segmentName: normalizedSegmentName,
              startTime: previousSegment.endTime!,
              endTime: now,
            );
            
            // Add segment to cache
            _cachedSegmentTimes = List.from(_cachedSegmentTimes)..add(segmentTime);
            
            segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
            notifyListeners();
          } else {
            throw Exception('Previous segment must be completed first');
          }
        } else {
          throw Exception('Segment must be started before it can be ended');
        }
      }
      
      // Perform actual update in the repository
      await _repository.endSegmentTime(bibNumber, segmentName);
    } catch (error) {
      // Revert optimistic update on error
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  /// Delete a segment time record
  Future<void> deleteSegmentTime(String bibNumber, String segmentName) async {
    final normalizedSegmentName = segmentName.toLowerCase();
    final segmentOrder = ['swim', 'cycle', 'run'];
    final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    try {
      // Remove current segment from cache
      _cachedSegmentTimes = List.from(_cachedSegmentTimes)
        ..removeWhere((time) => 
            time.participantBibNumber == bibNumber && 
            time.segmentName == normalizedSegmentName);
      
      segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      notifyListeners();
      
      // Perform actual update
      await _repository.deleteSegmentTime(bibNumber, segmentName);
    } catch (error) {
      // Revert optimistic update on error
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  /// Fetch all segment times
  Future<void> fetchSegmentTimes() async {
    try {
      // Set loading state only if we don't have cached data
      if (!_hasLoadedInitialData) {
        segmentTimesValue = const AsyncValue.loading();
        notifyListeners();
      }
      
      final segmentTimes = await _repository.getAllSegmentTimes();
      _cachedSegmentTimes = segmentTimes;
      _hasLoadedInitialData = true;
      segmentTimesValue = AsyncValue.success(segmentTimes);
      notifyListeners();
    } catch (error) {
      if (_hasLoadedInitialData) {
        // If we have cached data, keep using it on error
        segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      } else {
        segmentTimesValue = AsyncValue.error(error);
      }
      notifyListeners();
      // Don't rethrow the error to prevent app crashes
    }
  }
  
  /// Assign a BIB number to a specific finish time (two-step tracking)
  /// This creates a segment time with the given finish time for the BIB
  Future<void> assignBibToFinishTime(String bibNumber, String segmentName, DateTime finishTime) async {
    final normalizedSegmentName = segmentName.toLowerCase();
    final segmentOrder = ['swim', 'cycle', 'run'];
    final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    try {
      // Check if there's already a segment time for this participant and segment
      final existingIndex = _cachedSegmentTimes.indexWhere(
        (time) => time.participantBibNumber == bibNumber && 
                 time.segmentName == normalizedSegmentName
      );
      
      if (existingIndex != -1) {
        // If there's already a time for this BIB and segment, update it with the new finish time
        final existingTime = _cachedSegmentTimes[existingIndex];
        
        // Only update if the existing time doesn't have an end time
        if (existingTime.endTime == null) {
          final updatedTime = existingTime.copyWith(endTime: finishTime);
          
          // Update locally
          _cachedSegmentTimes = List.from(_cachedSegmentTimes)
            ..[existingIndex] = updatedTime;
          
          segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
          notifyListeners();
          
          // Update in repository
          await _repository.endSegmentTime(bibNumber, segmentName);
          return;
        } else {
          // Already has an end time, throw error
          throw Exception('Participant already has a time for this segment');
        }
      }
      
      // Determine the start time based on segment
      DateTime startTime;
      
      if (segmentIndex == 0) { // Swim (first segment)
        // For swim, try to find race start time, or use a reasonable time before finish
        final existingSwimSegments = _cachedSegmentTimes.where(
          (time) => time.segmentName == 'swim' && time.startTime != null
        );
        
        if (existingSwimSegments.isNotEmpty) {
          startTime = existingSwimSegments.first.startTime;
        } else {
          // Fallback to a minute before finish time
          startTime = finishTime.subtract(const Duration(minutes: 1));
        }
      } else { 
        // For other segments, use previous segment's end time
        final previousSegmentName = segmentOrder[segmentIndex - 1];
        
        // Find previous segment
        final previousSegmentList = _cachedSegmentTimes.where(
          (time) => time.participantBibNumber == bibNumber && 
                   time.segmentName == previousSegmentName &&
                   time.endTime != null
        ).toList();
        
        if (previousSegmentList.isNotEmpty) {
          startTime = previousSegmentList.first.endTime!;
        } else {
          // Fallback if previous segment not found
          throw Exception('Previous segment must be completed first');
        }
      }
      
      // Create new segment time
      final segmentTime = SegmentTime(
        participantBibNumber: bibNumber,
        segmentName: normalizedSegmentName,
        startTime: startTime,
        endTime: finishTime,
      );
      
      // Add to cached list
      _cachedSegmentTimes = List.from(_cachedSegmentTimes)..add(segmentTime);
      
      segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      notifyListeners();
      
      // Save to repository
      // First start the segment time, then end it
      await _repository.startSegmentTime(bibNumber, segmentName);
      await _repository.endSegmentTime(bibNumber, segmentName);
      
    } catch (error) {
      // Revert optimistic update on error
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  /// Get segment times for a specific segment
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName) async {
    return _repository.getSegmentTimesBySegment(segmentName);
  }
  
  /// Get segment times for a specific participant
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber) async {
    return _repository.getSegmentTimesByParticipant(bibNumber);
  }
  
  @override
  void dispose() {
    _segmentTimesSubscription?.cancel();
    super.dispose();
  }
} 