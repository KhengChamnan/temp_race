import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/segment_time_dto.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_race_repository.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/model/race.dart';

/// Firebase implementation of SegmentTimeRepository interface
/// Uses Firestore for storing and retrieving segment time data
class FirebaseSegmentTimeRepository implements SegmentTimeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseRaceRepository _raceRepository;
  
  // Collection path
  final String _segmentTimesCollection = 'segmentTimes';
  
  // Define segment order (same as in mock implementation)
  static const List<String> _segmentOrder = ['swim', 'cycle', 'run'];
  
  // Constructor with dependency injection for testing
  FirebaseSegmentTimeRepository({
    FirebaseFirestore? firestore,
    FirebaseRaceRepository? raceRepository
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _raceRepository = raceRepository ?? FirebaseRaceRepository();
  
  // Helper method to check if race is active
  Future<bool> _isRaceActive() async {
    try {
      final race = await _raceRepository.getCurrentRace();
      return race.status == RaceStatus.started;
    } catch (e) {
      print("Error checking if race is active: $e");
      
      // As a fallback, directly check Firestore
      try {
        final raceSnapshot = await _firestore
            .collection('races')
            .where('status', isEqualTo: 1) // RaceStatus.started.index = 1
            .limit(1)
            .get();
            
        return raceSnapshot.docs.isNotEmpty;
      } catch (innerError) {
        print("Fallback race active check failed: $innerError");
        return false;
      }
    }
  }
  
  // Helper method to create a unique document ID for a segment time
  String _createSegmentTimeId(String bibNumber, String segmentName) {
    return '${bibNumber}_${segmentName.toLowerCase()}';
  }

  @override
  Future<List<SegmentTime>> getAllSegmentTimes() async {
    try {
      final querySnapshot = await _firestore.collection(_segmentTimesCollection).get();
      return querySnapshot.docs.map((doc) => 
        SegmentTimeDto.fromJson(doc.id, doc.data())
      ).toList();
    } catch (e) {
      print("Error getting all segment times: $e");
      return [];
    }
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName) async {
    try {
      final normalizedSegmentName = segmentName.toLowerCase();
      final querySnapshot = await _firestore
          .collection(_segmentTimesCollection)
          .where('segmentName', isEqualTo: normalizedSegmentName)
          .get();
          
      return querySnapshot.docs.map((doc) => 
        SegmentTimeDto.fromJson(doc.id, doc.data())
      ).toList();
    } catch (e) {
      print("Error getting segment times by segment: $e");
      return [];
    }
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_segmentTimesCollection)
          .where('participantBibNumber', isEqualTo: bibNumber)
          .get();
          
      return querySnapshot.docs.map((doc) => 
        SegmentTimeDto.fromJson(doc.id, doc.data())
      ).toList();
    } catch (e) {
      print("Error getting segment times by participant: $e");
      return [];
    }
  }
  
  @override
  Future<SegmentTime> startSegmentTime(String bibNumber, String segmentName) async {
    // Check if race is active
    if (!await _isRaceActive()) {
      throw Exception('Cannot start segment time when race is not active');
    }

    // Normalize segment name
    final normalizedSegmentName = segmentName.toLowerCase();
    final currentSegmentIndex = _segmentOrder.indexOf(normalizedSegmentName);
    
    if (currentSegmentIndex == -1) {
      throw Exception('Invalid segment name: $segmentName');
    }

    // Create document ID
    final docId = _createSegmentTimeId(bibNumber, normalizedSegmentName);
    
    try {
      // Check if an entry already exists
      final docSnapshot = await _firestore
          .collection(_segmentTimesCollection)
          .doc(docId)
          .get();
      
      // If it already exists, return it (don't create a new one)
      if (docSnapshot.exists) {
        final existingSegmentTime = SegmentTimeDto.fromJson(docId, docSnapshot.data()!);
        return existingSegmentTime;
      }
      
      // For swim segment (first segment), we manually set the start time to now
      // For other segments, we don't manually start them - they should be started 
      // automatically when the previous segment ends
      if (normalizedSegmentName != 'swim') {
        throw Exception('Only the swim segment can be manually started. Other segments start automatically when previous segment ends.');
      }
      
      // For swim segment, create new entry with current time as start time
      final segmentTime = SegmentTime(
        participantBibNumber: bibNumber,
        segmentName: normalizedSegmentName,
        startTime: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore
          .collection(_segmentTimesCollection)
          .doc(docId)
          .set(SegmentTimeDto.toJson(segmentTime));
      
      return segmentTime;
    } catch (e) {
      print("Error starting segment time: $e");
      rethrow;
    }
  }
  
  @override
  Future<SegmentTime> endSegmentTime(String bibNumber, String segmentName) async {
    // Check if race is active
    if (!await _isRaceActive()) {
      throw Exception('Cannot end segment time when race is not active');
    }

    // Normalize segment name
    final normalizedSegmentName = segmentName.toLowerCase();
    final docId = _createSegmentTimeId(bibNumber, normalizedSegmentName);
    final segmentIndex = _segmentOrder.indexOf(normalizedSegmentName);
    
    if (segmentIndex == -1) {
      throw Exception('Invalid segment name: $segmentName');
    }
    
    try {
      // Check if current segment exists and has been started
      final docSnapshot = await _firestore
          .collection(_segmentTimesCollection)
          .doc(docId)
          .get();
      
      if (!docSnapshot.exists) {
        // For swim segment, we need to create it if it doesn't exist
        if (normalizedSegmentName == 'swim') {
          // Get race start time for swim segment
          final raceSnapshot = await _firestore
              .collection('races')
              .where('status', isEqualTo: 1) // RaceStatus.started.index = 1
              .limit(1)
              .get();
              
          if (raceSnapshot.docs.isEmpty) {
            throw Exception('Cannot find active race');
          }
          
          // Get race start time
          final raceData = raceSnapshot.docs.first.data();
          final raceStartTime = (raceData['startTime'] as Timestamp).toDate();
          
          // Create new segment time with race start time and current end time
          final now = DateTime.now();
          final segmentTime = SegmentTime(
            participantBibNumber: bibNumber,
            segmentName: normalizedSegmentName,
            startTime: raceStartTime,
            endTime: now,
          );
          
          // Save to Firestore
          await _firestore
              .collection(_segmentTimesCollection)
              .doc(docId)
              .set(SegmentTimeDto.toJson(segmentTime));
          
          return segmentTime;
        } else {
          // For non-swim segments, check if previous segment exists and has ended
          if (segmentIndex > 0) {
            final previousSegmentName = _segmentOrder[segmentIndex - 1];
            final previousDocId = _createSegmentTimeId(bibNumber, previousSegmentName);
            
            final previousDocSnapshot = await _firestore
                .collection(_segmentTimesCollection)
                .doc(previousDocId)
                .get();
                
            if (!previousDocSnapshot.exists) {
              throw Exception('Previous segment must be completed first');
            }
            
            final previousSegmentTime = SegmentTimeDto.fromJson(
              previousDocId, 
              previousDocSnapshot.data()!
            );
            
            if (previousSegmentTime.endTime == null) {
              throw Exception('Previous segment must be completed first');
            }
            
            // Auto-create this segment with start time from previous segment's end time
            final now = DateTime.now();
            final segmentTime = SegmentTime(
              participantBibNumber: bibNumber,
              segmentName: normalizedSegmentName,
              startTime: previousSegmentTime.endTime!,
              endTime: now,
            );
            
            // Save to Firestore
            await _firestore
                .collection(_segmentTimesCollection)
                .doc(docId)
                .set(SegmentTimeDto.toJson(segmentTime));
            
            return segmentTime;
          } else {
            throw Exception('Segment must be started before it can be ended');
          }
        }
      } else {
        // Segment exists - update it with end time
        final existingTime = SegmentTimeDto.fromJson(docId, docSnapshot.data()!);
        
        // Check if it already has an end time
        if (existingTime.endTime != null) {
          return existingTime; // Already ended
        }
        
        // Set the end time to now
        final now = DateTime.now();
        final updatedTime = existingTime.copyWith(
          endTime: now,
        );
        
        // Update in Firestore
        await _firestore
            .collection(_segmentTimesCollection)
            .doc(docId)
            .update({'endTime': Timestamp.fromDate(now)});
        
        return updatedTime;
      }
    } catch (e) {
      print("Error ending segment time: $e");
      rethrow;
    }
  }
  
  @override
  Future<void> deleteSegmentTime(String bibNumber, String segmentName) async {
    // Check if race is active
    if (!await _isRaceActive()) {
      throw Exception('Cannot delete segment time when race is not active');
    }

    // Normalize segment name
    final normalizedSegmentName = segmentName.toLowerCase();
    final docId = _createSegmentTimeId(bibNumber, normalizedSegmentName);
    
    try {
      // Get the current segment record first to check if it exists
      final docSnapshot = await _firestore
          .collection(_segmentTimesCollection)
          .doc(docId)
          .get();
          
      if (!docSnapshot.exists) {
        // Nothing to delete
        return;
      }
      
      // Delete from Firestore
      await _firestore
          .collection(_segmentTimesCollection)
          .doc(docId)
          .delete();
    } catch (e) {
      print("Error deleting segment time: $e");
      rethrow;
    }
  }
  
  @override
  Stream<List<SegmentTime>> getSegmentTimesStream() {
    return _firestore
        .collection(_segmentTimesCollection)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs
              .map((doc) => SegmentTimeDto.fromJson(doc.id, doc.data()))
              .toList()
        );
  }
} 