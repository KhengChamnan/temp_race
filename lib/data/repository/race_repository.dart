import 'package:race_traking_app/model/race.dart';

/// Abstract repository interface for race operations
abstract class RaceRepository {
  /// Get the current race
  Future<Race> getCurrentRace();
  
  /// Get a stream of the current race for real-time updates
  Stream<Race> getRaceStream();
  
  /// Start the race
  Future<void> startRace();
  
  /// Finish the race
  Future<void> finishRace();
  
  /// Reset the race
  Future<void> resetRace();
  

}