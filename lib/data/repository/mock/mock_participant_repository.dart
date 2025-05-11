import 'dart:async';

import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/utils/participant_repository_helper.dart';
import 'package:race_traking_app/utils/bib_number_generator.dart';

class MockParticipantRepository implements ParticipantRepository {
  final List<Participant> _participants = [
    const Participant(
    bibNumber: "001",
    firstName: "Cham",
    lastName: "Kun",
    age: 32,
    gender: "Male",
  ),
  const Participant(
    bibNumber: "002",
    firstName: "Leou",
    lastName: "Kun",
    age: 28,
    gender: "Female",
  ),
  const Participant(
    bibNumber: "003",
    firstName: "Ram",
    lastName: "Kun",
    age: 45,
    gender: "Male",
  ),
  const Participant(
    bibNumber: "004",
    firstName: "Ra",
    lastName: "Kun",
    age: 30,
    gender: "Female",
  ),
  ];

  @override
  Stream<List<Participant>> getParticipantsStream() {
    return Stream.fromFuture(getAllParticipants());
  }

  @override
  Future<List<Participant>> getAllParticipants() async {
    return List.from(_participants); 
  }

  @override
  Future<Participant?> getParticipantByBib(String bibNumber) async {
    try {
      return _participants.firstWhere((participant) => participant.bibNumber == bibNumber);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addParticipant(Participant participant) async {
    final existingIndex = _participants.indexWhere((p) => p.bibNumber == participant.bibNumber);
    if (existingIndex != -1) {
      BibNumberGenerator.sortParticipantsByBib(_participants);
      ParticipantRepositoryHelper.shiftBibNumbersUpForInsert(_participants, participant.bibNumber);
    }
    
    _participants.add(participant);
  }

  @override
  Future<void> updateParticipant(Participant participant) async {
    final index = _participants.indexWhere((p) => p.bibNumber == participant.bibNumber);
    
    if (index != -1) {
      _participants[index] = participant;
    } else {
      final existingParticipant = ParticipantRepositoryHelper.findParticipantByName(
        _participants,
        participant.firstName,
        participant.lastName
      );
      
      if (existingParticipant != null) {
        _participants.removeWhere(
          (p) => p.firstName == participant.firstName && p.lastName == participant.lastName
        );
        _participants.add(participant);
      } else {
        _participants.add(participant);
      }
    }
  }

  @override
  Future<void> deleteParticipant(String bibNumber) async {
    BibNumberGenerator.sortParticipantsByBib(_participants);
    
    ParticipantRepositoryHelper.shiftBibNumbersDownAfterDelete(_participants, bibNumber);
    
    BibNumberGenerator.sortParticipantsByBib(_participants);
  }
}