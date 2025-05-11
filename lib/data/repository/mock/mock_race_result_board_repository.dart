import 'dart:async';

import 'package:race_traking_app/data/repository/race_result_board_repository.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';


/// Mock implementation of the RaceResultBoardRepository interface
/// Uses in-memory storage and composition of other repositories
class MockRaceResultBoardRepository implements RaceResultBoardRepository {
  final RaceRepository _raceRepository;
  final ParticipantRepository _participantRepository;
  final SegmentTimeRepository _segmentTimeRepository;
  
  // Cache for the current race result board
  RaceResultBoard? _currentRaceResultBoard;
  
  // StreamController to broadcast race result board updates
  final _raceResultBoardStreamController = StreamController<RaceResultBoard>.broadcast();
  
  MockRaceResultBoardRepository({
    required RaceRepository raceRepository,
    required ParticipantRepository participantRepository,
    required SegmentTimeRepository segmentTimeRepository,
  }) : 
    _raceRepository = raceRepository,
    _participantRepository = participantRepository,
    _segmentTimeRepository = segmentTimeRepository {
      // Listen to segment time updates to refresh the race result board
      _segmentTimeRepository.getSegmentTimesStream().listen((_) async {
        // When segment times update, refresh the race result board
        final race = await _raceRepository.getCurrentRace();
        await generateRaceResultBoard(race);
      });
    }
  
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
  
  @override
  Future<RaceResultBoard> getCurrentRaceResultBoard() async {
    if (_currentRaceResultBoard == null) {
      final race = await _raceRepository.getCurrentRace();
      return generateRaceResultBoard(race);
    }
    return _currentRaceResultBoard!;
  }
  
  @override
  Stream<RaceResultBoard> getRaceResultBoardStream() {
    return _raceResultBoardStreamController.stream;
  }
  
  @override
  Future<RaceResultBoard> getRaceResultBoardByRace(Race race) async {
    return _buildRaceResultBoard(race);
  }
  
  @override
  Future<RaceResultBoard> generateRaceResultBoard(Race race) async {
    final board = await _buildRaceResultBoard(race);
    
    // Cache the current race result board
    _currentRaceResultBoard = board;
    
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
    // Mock implementation for exporting race results
    final board = await getRaceResultBoardByRace(race);
    
    // In a real implementation, this would generate a file in the specified format
    // For the mock, we'll just return a string indicating it was "exported"
    
    switch (format.toLowerCase()) {
      case 'csv':
        return _generateMockCsv(board);
      case 'pdf':
        return 'Race results exported as PDF';
      case 'json':
        return 'Race results exported as JSON';
      default:
        throw Exception('Unsupported export format: $format');
    }
  }
  
  /// Helper to generate a mock CSV string
  String _generateMockCsv(RaceResultBoard board) {
    // Simple CSV header
    String csv = 'Rank,Bib,Name,Total Time\n';
    
    // Add data for each participant
    for (var item in board.resultItems) {
      csv += '${item.rank},${item.bibNumber},${item.participantName},${item.formattedTotalDuration}\n';
    }
    
    return csv;
  }
  
  void dispose() {
    _raceResultBoardStreamController.close();
  }
} 