import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';

/// Abstract repository interface for race result board operations
abstract class RaceResultBoardRepository {
  /// Get the current race result board
  Future<RaceResultBoard> getCurrentRaceResultBoard();
  
  /// Get a stream of the race result board for real-time updates
  Stream<RaceResultBoard> getRaceResultBoardStream();
  
  /// Get results for a specific race
  Future<RaceResultBoard> getRaceResultBoardByRace(Race race);
  
  /// Generate and save a race result board
  Future<RaceResultBoard> generateRaceResultBoard(Race race);
  
  /// Get race result item for a specific participant
  Future<RaceResultItem?> getResultItemByParticipant(String bibNumber, Race race);
  
  /// Export race results to a file format (e.g., CSV, PDF)
  Future<String> exportRaceResults(Race race, String format);
} 