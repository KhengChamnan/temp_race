import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/race_result_board_dto.dart';
import 'package:race_traking_app/data/repository/race_result_board_repository.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';

/// Firebase implementation of the RaceResultBoardRepository interface
/// Uses Firestore for storage and composition of other repositories
class FirebaseRaceResultBoardRepository implements RaceResultBoardRepository {
  final FirebaseFirestore _firestore;
  final RaceRepository _raceRepository;
  final ParticipantRepository _participantRepository;
  final SegmentTimeRepository _segmentTimeRepository;
  
  // Cache for the current race result board
  RaceResultBoard? _currentRaceResultBoard;
  
  // StreamController to broadcast race result board updates
  final _raceResultBoardStreamController = StreamController<RaceResultBoard>.broadcast();
  
  // Subscription to race updates
  StreamSubscription? _raceSubscription;
  
  FirebaseRaceResultBoardRepository({
    FirebaseFirestore? firestore,
    required RaceRepository raceRepository,
    required ParticipantRepository participantRepository,
    required SegmentTimeRepository segmentTimeRepository,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _raceRepository = raceRepository,
    _participantRepository = participantRepository,
    _segmentTimeRepository = segmentTimeRepository {
      // Listen to segment time updates to refresh the race result board
      _segmentTimeRepository.getSegmentTimesStream().listen((_) async {
        // When segment times update, refresh the race result board
        final race = await _raceRepository.getCurrentRace();
        await _updateRaceResultBoard(race);
      });
      
      // Listen to race status changes
      _raceSubscription = _raceRepository.getRaceStream().listen((race) async {
        if (race.status == RaceStatus.finished) {
          // Only save to Firestore when race is finished
          final board = await _buildRaceResultBoard(race);
          _currentRaceResultBoard = board;
          await _saveToFirestore(board);
          _notifyListeners(board);
        } else if (race.status == RaceStatus.notStarted) {
          // Race was reset, clear the cached result board
          _currentRaceResultBoard = null;
          
          // Calculate a new board but don't save to Firestore
          final board = await _buildRaceResultBoard(race);
          _notifyListeners(board);
        }
      });
    }
  
  // Helper to get collection reference
  CollectionReference get _raceResultBoardCollection => 
      _firestore.collection('raceResultBoards');
  
  /// Helper method to build a race result board from its components
  Future<RaceResultBoard> _buildRaceResultBoard(Race race) async {
    final participants = await _participantRepository.getAllParticipants();
    final segmentTimes = await _segmentTimeRepository.getAllSegmentTimes();
    
    return RaceResultBoard.createFromData(
      race: race,
      participants: participants,
      segmentTimes: segmentTimes,
    );
  }
  
  /// Helper to notify listeners of an update
  void _notifyListeners(RaceResultBoard board) {
    if (!_raceResultBoardStreamController.isClosed) {
      _raceResultBoardStreamController.add(board);
    }
  }
  
  /// Save race result board to Firestore - ONLY for finished races
  Future<void> _saveToFirestore(RaceResultBoard board) async {
    // Only save if race is finished
    if (board.race.status != RaceStatus.finished) {
      return;
    }
    
    try {
      final docId = board.race.date.toIso8601String();
      await _raceResultBoardCollection.doc(docId).set(
        RaceResultBoardDto.toJson(board)
      );
    } catch (e) {
      print('Error saving race result board to Firestore: $e');
      // Error is caught but not rethrown to prevent UI disruption
    }
  }
  
  /// Update race result board but only save to Firestore if race is finished
  Future<RaceResultBoard> _updateRaceResultBoard(Race race) async {
    final board = await _buildRaceResultBoard(race);
    
    // Cache locally
    _currentRaceResultBoard = board;
    
    // Only save to Firestore if race is finished
    if (race.status == RaceStatus.finished) {
      await _saveToFirestore(board);
    }
    
    // Notify listeners of the update
    _notifyListeners(board);
    
    return board;
  }
  
  @override
  Future<RaceResultBoard> getCurrentRaceResultBoard() async {
    if (_currentRaceResultBoard != null) {
      return _currentRaceResultBoard!;
    }
    
    try {
      final race = await _raceRepository.getCurrentRace();
      
      // Only look for finished race results in Firestore
      if (race.status == RaceStatus.finished) {
        final docId = race.date.toIso8601String();
        final docSnapshot = await _raceResultBoardCollection.doc(docId).get();
        
        if (docSnapshot.exists && docSnapshot.data() != null) {
          // Document exists in Firestore, parse it
          final board = RaceResultBoardDto.fromJson(
            docId, 
            docSnapshot.data() as Map<String, dynamic>
          );
          _currentRaceResultBoard = board;
          return board;
        }
      }
      
      // For races that are not finished or not in Firestore, just build the board locally
      return _updateRaceResultBoard(race);
    } catch (e) {
      print('Error getting current race result board: $e');
      // If there's an error, fall back to generating the board
      final race = await _raceRepository.getCurrentRace();
      return _updateRaceResultBoard(race);
    }
  }
  
  @override
  Stream<RaceResultBoard> getRaceResultBoardStream() async* {
    try {
      final race = await _raceRepository.getCurrentRace();
      
      // Only use Firestore stream for finished races
      if (race.status == RaceStatus.finished) {
        final docId = race.date.toIso8601String();
        
        yield* _raceResultBoardCollection.doc(docId)
          .snapshots()
          .asyncMap((snapshot) async {
            if (snapshot.exists && snapshot.data() != null) {
              // Parse data from Firestore
              final board = RaceResultBoardDto.fromJson(
                docId, 
                snapshot.data() as Map<String, dynamic>
              );
              _currentRaceResultBoard = board;
              return board;
            } else {
              // For finished races with no document, create it
              final newBoard = await _buildRaceResultBoard(race);
              _currentRaceResultBoard = newBoard;
              await _saveToFirestore(newBoard);
              return newBoard;
            }
          });
      } else {
        // For active or not started races, use the local stream
        // First emit the current board if available
        if (_currentRaceResultBoard != null) {
          yield _currentRaceResultBoard!;
        } else {
          // Generate an initial board
          final board = await _buildRaceResultBoard(race);
          _currentRaceResultBoard = board;
          yield board;
        }
        
        // Then continue with updates from stream controller
        yield* _raceResultBoardStreamController.stream;
      }
    } catch (e) {
      print('Error setting up race result board stream: $e');
      // Fallback to local updates via the StreamController
      yield* _raceResultBoardStreamController.stream;
    }
  }
  
  @override
  Future<RaceResultBoard> getRaceResultBoardByRace(Race race) async {
    // Only look in Firestore for finished races
    if (race.status == RaceStatus.finished) {
      try {
        final docId = race.date.toIso8601String();
        final docSnapshot = await _raceResultBoardCollection.doc(docId).get();
        
        if (docSnapshot.exists && docSnapshot.data() != null) {
          // Document exists in Firestore
          return RaceResultBoardDto.fromJson(
            docId, 
            docSnapshot.data() as Map<String, dynamic>
          );
        }
      } catch (e) {
        print('Error getting race result board by race: $e');
      }
    }
    
    // For non-finished races or if Firestore access fails, build it dynamically
    return _buildRaceResultBoard(race);
  }
  
  @override
  Future<RaceResultBoard> generateRaceResultBoard(Race race) async {
    // Generate the board
    final board = await _buildRaceResultBoard(race);
    
    // Cache locally
    _currentRaceResultBoard = board;
    
    // Only save to Firestore if race is finished
    if (race.status == RaceStatus.finished) {
      await _saveToFirestore(board);
    }
    
    // Notify listeners
    _notifyListeners(board);
    
    return board;
  }
  
  @override
  Future<RaceResultItem?> getResultItemByParticipant(String bibNumber, Race race) async {
    final board = await getRaceResultBoardByRace(race);
    
    try {
      return board.resultItems.firstWhere(
        (item) => item.bibNumber == bibNumber
      );
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<String> exportRaceResults(Race race, String format) async {
    final board = await getRaceResultBoardByRace(race);
    
    switch (format.toLowerCase()) {
      case 'csv':
        return _generateCsv(board);
      case 'pdf':
        return 'Race results exported as PDF';
      case 'json':
        return 'Race results exported as JSON';
      default:
        throw Exception('Unsupported export format: $format');
    }
  }
  
  /// Helper to generate a CSV string
  String _generateCsv(RaceResultBoard board) {
    // Enhanced CSV header with all segment times
    String csv = 'Rank,Bib,Name,Cycle Time,Run Time,Swim Time,Total Time\n';
    
    // Add data for each participant
    for (var item in board.resultItems) {
      final cycleTime = item.getSegmentTime('cycle')?.formattedDuration ?? '--:--:--';
      final runTime = item.getSegmentTime('run')?.formattedDuration ?? '--:--:--';
      final swimTime = item.getSegmentTime('swim')?.formattedDuration ?? '--:--:--';
      
      csv += '${item.rank},${item.bibNumber},${item.participantName},$cycleTime,$runTime,$swimTime,${item.formattedTotalDuration}\n';
    }
    
    return csv;
  }
  
  void dispose() {
    _raceResultBoardStreamController.close();
    _raceSubscription?.cancel();
  }
} 