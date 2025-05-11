import 'package:race_traking_app/model/segment_time.dart';

/// Abstract repository interface for segment time operations
abstract class SegmentTimeRepository {
  /// Get all segment times for a race
  Future<List<SegmentTime>> getAllSegmentTimes();
  
  /// Get segment times for a specific segment
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName);
  
  /// Get segment times for a specific participant
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber);
  
  /// Record start time for a participant in a segment
  Future<SegmentTime> startSegmentTime(String bibNumber, String segmentName);
  
  /// Record end time for a participant in a segment
  Future<SegmentTime> endSegmentTime(String bibNumber, String segmentName);
  
  /// Delete a segment time record (in case of error)
  Future<void> deleteSegmentTime(String bibNumber, String segmentName);
  
  /// Get stream of segment times for real-time updates
  Stream<List<SegmentTime>> getSegmentTimesStream();
} 