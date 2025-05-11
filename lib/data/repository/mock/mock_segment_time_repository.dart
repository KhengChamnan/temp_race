import 'dart:async';

import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/model/race.dart';

/// Mock implementation of SegmentTimeRepository for testing and development
class MockSegmentTimeRepository implements SegmentTimeRepository {
  // In-memory storage of segment times
  final List<SegmentTime> _segmentTimes = [];
  
  // StreamController to simulate real-time updates
  final _segmentTimesStreamController = StreamController<List<SegmentTime>>.broadcast();

  // Reference to race repository to check race status
  final RaceRepository _raceRepository;
  
  // Define segment order
  static const List<String> segmentOrder = ['swim', 'cycle', 'run'];
  
  MockSegmentTimeRepository({required RaceRepository raceRepository}) 
    : _raceRepository = raceRepository {
    // Initialize with some sample data if needed
    // _initializeMockData();
    
    // Emit initial empty list
    _notifyListeners();
  }

  // Helper method to check if race is active
  Future<bool> _isRaceActive() async {
    final race = await _raceRepository.getCurrentRace();
    return race.status == RaceStatus.started;
  }



  @override
  Future<List<SegmentTime>> getAllSegmentTimes() async {
    // Return a copy of the list to prevent external modification
    return List.from(_segmentTimes);
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName) async {
    return _segmentTimes
        .where((time) => time.segmentName.toLowerCase() == segmentName.toLowerCase())
        .toList();
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber) async {
    return _segmentTimes
        .where((time) => time.participantBibNumber == bibNumber)
        .toList();
  }
  
  @override
  Future<SegmentTime> startSegmentTime(String bibNumber, String segmentName) async {
    // Check if race is active
    if (!await _isRaceActive()) {
      throw Exception('Cannot start segment time when race is not active');
    }

    // Normalize segment name
    final normalizedSegmentName = segmentName.toLowerCase();
    final currentSegmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    if (currentSegmentIndex == -1) {
      throw Exception('Invalid segment name: $segmentName');
    }

    // Check if an entry already exists
    final existingIndex = _segmentTimes.indexWhere(
      (time) => 
          time.participantBibNumber == bibNumber && 
          time.segmentName.toLowerCase() == normalizedSegmentName
    );
    
    if (existingIndex != -1) {
      // If it exists but has an end time, consider it a new start
      if (_segmentTimes[existingIndex].endTime != null) {
        // Remove the old entry
        _segmentTimes.removeAt(existingIndex);
      } else {
        // If it exists without an end time, return the existing one
        return _segmentTimes[existingIndex];
      }
    }
    
    DateTime startTime = DateTime.now();
    
    // If this is not the first segment, check if previous segment is completed
    if (currentSegmentIndex > 0) {
      final previousSegment = segmentOrder[currentSegmentIndex - 1];
      try {
        final previousSegmentTime = _segmentTimes.lastWhere(
          (time) => 
              time.participantBibNumber == bibNumber && 
              time.segmentName.toLowerCase() == previousSegment,
        );
        
        // Check if previous segment is completed
        if (!previousSegmentTime.isCompleted) {
          throw Exception('Previous segment ($previousSegment) must be completed first');
        }
        
        // Use the end time of previous segment as start time for this segment
        startTime = previousSegmentTime.endTime!;
      } catch (e) {
        // If previous segment not found
        throw Exception('Previous segment ($previousSegment) must be completed first');
      }
    }
    
    // Create new segment time
    final segmentTime = SegmentTime(
      participantBibNumber: bibNumber,
      segmentName: normalizedSegmentName,
      startTime: startTime,
    );
    
    // Add to list
    _segmentTimes.add(segmentTime);
    
    // Notify listeners
    _notifyListeners();
    
    return segmentTime;
  }
  
  @override
  Future<SegmentTime> endSegmentTime(String bibNumber, String segmentName) async {
    // Check if race is active
    if (!await _isRaceActive()) {
      throw Exception('Cannot end segment time when race is not active');
    }

    // Normalize segment name
    final normalizedSegmentName = segmentName.toLowerCase();

    // Find the segment time
    final index = _segmentTimes.indexWhere(
      (time) => 
          time.participantBibNumber == bibNumber && 
          time.segmentName.toLowerCase() == normalizedSegmentName
    );
    
    if (index == -1) {
      throw Exception('Cannot end segment time that hasn\'t started');
    }
    
    // Get existing segment time
    final existingTime = _segmentTimes[index];
    
    // Check if it already has an end time
    if (existingTime.endTime != null) {
      return existingTime; // Already ended
    }
    
    // Create updated segment time with end time
    final updatedTime = existingTime.copyWith(
      endTime: DateTime.now(),
    );
    
    // Update in list
    _segmentTimes[index] = updatedTime;
    
    // Notify listeners
    _notifyListeners();
    
    return updatedTime;
  }
  
  @override
  Future<void> deleteSegmentTime(String bibNumber, String segmentName) async {
    // Check if race is active
    if (!await _isRaceActive()) {
      throw Exception('Cannot delete segment time when race is not active');
    }

    // Normalize segment name
    final normalizedSegmentName = segmentName.toLowerCase();

    // Check if this would break segment order
    final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    if (segmentIndex < segmentOrder.length - 1) {
      // Check if any later segments exist
      final hasLaterSegments = _segmentTimes.any((time) => 
          time.participantBibNumber == bibNumber && 
          segmentOrder.indexOf(time.segmentName.toLowerCase()) > segmentIndex
      );
      
      if (hasLaterSegments) {
        throw Exception('Cannot delete a segment when later segments exist');
      }
    }

    _segmentTimes.removeWhere(
      (time) => 
          time.participantBibNumber == bibNumber && 
          time.segmentName.toLowerCase() == normalizedSegmentName
    );
    
    // Notify listeners
    _notifyListeners();
  }
  
  @override
  Stream<List<SegmentTime>> getSegmentTimesStream() {
    // Return stream from controller
    return _segmentTimesStreamController.stream;
  }
  
  // Helper to notify stream listeners
  void _notifyListeners() {
    _segmentTimesStreamController.add(List.from(_segmentTimes));
  }
  
  // Cleanup resources
  void dispose() {
    _segmentTimesStreamController.close();
  }
} 