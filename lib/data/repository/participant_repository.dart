import 'package:race_traking_app/model/participant.dart';

abstract class ParticipantRepository {
  Future<List<Participant>> getAllParticipants();
  Future<Participant?> getParticipantByBib(String bibNumber);
  Future<void> addParticipant(Participant participant);
  Future<void> updateParticipant(Participant participant);
  Future<void> deleteParticipant(String bibNumber);
  
  Stream<List<Participant>> getParticipantsStream();
} 