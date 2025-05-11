import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/race_dto.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_participant_repository.dart';

/// Firebase implementation of the RaceRepository interface
/// Uses Firestore for storing and retrieving race data
/// When a race is reset, this implementation also clears all segment times
/// from the segmentTimes collection
class FirebaseRaceRepository implements RaceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseParticipantRepository _participantRepository;
  
  // Collection and document paths
  final String _racesCollection = 'races';
  final String _currentRaceDoc = 'current'; // We'll use a fixed document ID for the current race

  FirebaseRaceRepository({
    FirebaseFirestore? firestore,
    FirebaseParticipantRepository? participantRepository
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _participantRepository = participantRepository ?? FirebaseParticipantRepository();
  
  Future<void> _createDefaultRace() async {
    // Get all participants to create a default race
    final participants = await _participantRepository.getAllParticipants();
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    final defaultRace = Race(
      date: DateTime.now(),
      status: RaceStatus.notStarted,
      participantBibNumbers: bibNumbers,
    );
    
    // Save to Firestore using RaceDto
    await _firestore
        .collection(_racesCollection)
        .doc(_currentRaceDoc)
        .set(RaceDto.toJson(defaultRace));
  }

  @override
  Stream<Race> getRaceStream() {
    // Create a transformer to handle the document snapshots
    return _firestore
        .collection(_racesCollection)
        .doc(_currentRaceDoc)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.exists) {
            final raceData = snapshot.data()!;
            
            // If critical fields are missing, create a default race
            if (!raceData.containsKey('date') || !raceData.containsKey('status')) {
              await _createDefaultRace();
              return getCurrentRace();
            }
            
            // Get latest participants to ensure race has up-to-date data
            final participants = await _participantRepository.getAllParticipants();
            final bibNumbers = participants.map((p) => p.bibNumber).toList();
            
            // Convert to Race model
            Race race = RaceDto.fromJson(_currentRaceDoc, raceData);
            
            // Update participant list if needed
            if (race.participantBibNumbers.length != bibNumbers.length ||
                !_areListsEqual(race.participantBibNumbers, bibNumbers)) {
              race = race.copyWith(participantBibNumbers: bibNumbers);
              
              // Update Firestore with latest participants (don't await to avoid blocking the stream)
              _firestore
                  .collection(_racesCollection)
                  .doc(_currentRaceDoc)
                  .update({'participantBibNumbers': bibNumbers})
                  .catchError((error) => print("Error updating race participants: $error"));
            }
            
            return race;
          } else {
            // If race doesn't exist, create a default one
            await _createDefaultRace();
            return getCurrentRace();
          }
        });
  }
  
  // Helper method to compare two lists
  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    list1.sort();
    list2.sort();
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  Future<Race> getCurrentRace() async {
    try {
      // Get participants first to ensure we have the latest
      final participants = await _participantRepository.getAllParticipants();
      final bibNumbers = participants.map((p) => p.bibNumber).toList();
      
      // Get the current race document
      final docSnapshot = await _firestore
          .collection(_racesCollection)
          .doc(_currentRaceDoc)
          .get();
      
      if (docSnapshot.exists) {
        final raceData = docSnapshot.data()!;
        
        // Check if the required fields exist in the document
        // This handles potential schema differences between devices
        if (!raceData.containsKey('date') || 
            !raceData.containsKey('status')) {
          // Critical fields missing, recreate the race
          await _createDefaultRace();
          return getCurrentRace(); // Try again
        }
        
        // Safely convert from Firestore
        Race race = RaceDto.fromJson(_currentRaceDoc, raceData);
        
        // Update with latest participants if needed
        if (race.participantBibNumbers.length != bibNumbers.length ||
            !_areListsEqual(race.participantBibNumbers, bibNumbers)) {
          race = race.copyWith(participantBibNumbers: bibNumbers);
          
          // Update Firestore with the latest participants
          await _firestore
              .collection(_racesCollection)
              .doc(_currentRaceDoc)
              .update({'participantBibNumbers': bibNumbers});
        }
        
        return race;
      } else {
        // If race doesn't exist, create a default one
        await _createDefaultRace();
        
        // Fetch it again
        final newDocSnapshot = await _firestore
            .collection(_racesCollection)
            .doc(_currentRaceDoc)
            .get();
        
        if (!newDocSnapshot.exists) {
          throw Exception("Failed to create race document");
        }
        
        return RaceDto.fromJson(_currentRaceDoc, newDocSnapshot.data()!);
      }
    } catch (error) {
      // Provide more specific error information
      print("Error in getCurrentRace: $error");
      throw Exception("Couldn't get race data: ${error.toString()}");
    }
  }
  
  @override
  Future<void> startRace() async {
    try {
      // Get the current race first
      await getCurrentRace();
      
      // Check if there are any participants
      final participantRepo = FirebaseParticipantRepository();
      final participants = await participantRepo.getAllParticipants();
      
      if (participants.isEmpty) {
        throw Exception('Cannot start race without participants');
      }
      
      // Update race in Firestore
      await _firestore
          .collection(_racesCollection)
          .doc(_currentRaceDoc)
          .update({
            'startTime': Timestamp.fromDate(DateTime.now()),
            'status': RaceStatus.started.index,
          });
    } catch (error) {
      rethrow;
    }
  }
  
  @override
  Future<void> finishRace() async {
    try {
      await _firestore
          .collection(_racesCollection)
          .doc(_currentRaceDoc)
          .update({
            'endTime': Timestamp.fromDate(DateTime.now()),
            'status': RaceStatus.finished.index,
          });
    } catch (error) {
      rethrow;
    }
  }
  
  @override
  Future<void> resetRace() async {
    try {
      // Get fresh participants when resetting
      final participants = await _participantRepository.getAllParticipants();
      final bibNumbers = participants.map((p) => p.bibNumber).toList();
      
      // Create a completely new race document
      final newRace = Race(
        date: DateTime.now(),
        status: RaceStatus.notStarted,
        startTime: null,
        endTime: null,
        participantBibNumbers: bibNumbers,
      );
      
      // Clear all segment times from the segmentTimes collection
      final segmentTimesCollection = 'segmentTimes';
      final segmentTimesSnapshot = await _firestore.collection(segmentTimesCollection).get();
      final batch = _firestore.batch();
      
      for (final doc in segmentTimesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Update or create the race document using RaceDto
      batch.set(
        _firestore.collection(_racesCollection).doc(_currentRaceDoc),
        RaceDto.toJson(newRace)
      );
      
      // Commit all operations in a single batch
      await batch.commit();
    } catch (error) {
      print("Error resetting race: $error");
      rethrow;
    }
  }
} 