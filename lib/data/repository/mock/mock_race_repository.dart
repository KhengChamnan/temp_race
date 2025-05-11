import 'dart:async';

import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_participant_repository.dart';

/// Mock implementation of the RaceRepository interface
/// Uses in-memory storage of race data for testing and development
class MockRaceRepository implements RaceRepository {
  final MockParticipantRepository _participantRepository = MockParticipantRepository();
  
  Race currentRace = Race(
    date: DateTime.now(),
    status: RaceStatus.notStarted,
    participantBibNumbers: [],
  );

  MockRaceRepository() {
    // Initialize with participants
    _initializeRace();
  }

  Future<void> _initializeRace() async {
    final participants = await _participantRepository.getAllParticipants();
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    currentRace = currentRace.copyWith(
      participantBibNumbers: bibNumbers,
    );
  }

  @override
  Future<Race> getCurrentRace() async {
    // Get all participants from the participant repository
    final participants = await _participantRepository.getAllParticipants();
    
    // Extract the bib numbers
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    // Update the race with the current participants
    currentRace = currentRace.copyWith(
      participantBibNumbers: bibNumbers,
    );
    
    return currentRace;
  }
  
  // Helper method to update race
  void _updateRace(Race updatedRace) {
    currentRace = updatedRace;
  }
  
  @override
  Future<void> startRace() async {
    // Make sure we have the latest participants before starting
    await getCurrentRace();
    
    final updatedRace = currentRace.copyWith(
      startTime: DateTime.now(),
      status: RaceStatus.started,
    );
    
    _updateRace(updatedRace);
  }
  
  @override
  Future<void> finishRace() async {
    final updatedRace = currentRace.copyWith(
      endTime: DateTime.now(),
      status: RaceStatus.finished,
    );
    
    _updateRace(updatedRace);
  }
  
  @override
  Future<void> resetRace() async {
    // Get fresh participants when resetting
    final participants = await _participantRepository.getAllParticipants();
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    // Create a completely new race instance with fresh date
    currentRace = Race(
      date: DateTime.now(),
      status: RaceStatus.notStarted,
      startTime: null,
      endTime: null,
      participantBibNumbers: bibNumbers,
    );
  }

  @override
  Stream<Race> getRaceStream() {
    return Stream.periodic(const Duration(seconds: 1), (i) => currentRace);
  }
}