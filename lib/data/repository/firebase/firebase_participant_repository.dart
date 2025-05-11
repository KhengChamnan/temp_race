import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/participant_dto.dart';
import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/utils/participant_repository_helper.dart';

class FirebaseParticipantRepository implements ParticipantRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'participants';

  FirebaseParticipantRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Participant>> getParticipantsStream() {
    return _firestore.collection(_collectionPath)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs
              .map((doc) => ParticipantDto.fromJson(doc.id, doc.data()))
              .toList()
        );
  }

  @override
  Future<List<Participant>> getAllParticipants() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs.map((doc) => 
        ParticipantDto.fromJson(doc.id, doc.data())
      ).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Participant?> getParticipantByBib(String bibNumber) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(bibNumber).get();
      if (doc.exists) {
        return ParticipantDto.fromJson(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addParticipant(Participant participant) async {
    try {
      final existingDoc = await _firestore.collection(_collectionPath)
          .doc(participant.bibNumber).get();
      
      if (existingDoc.exists) {
        final querySnapshot = await _firestore.collection(_collectionPath).get();
        final participants = querySnapshot.docs.map((doc) => 
          ParticipantDto.fromJson(doc.id, doc.data())
        ).toList();
        
        final batch = ParticipantRepositoryHelper.createBibShiftUpBatch(
          _firestore,
          participants,
          _collectionPath,
          participant.bibNumber,
          participant
        );
        
        await batch.commit();
      } else {
        await _firestore.collection(_collectionPath)
            .doc(participant.bibNumber)
            .set(ParticipantDto.toJson(participant));
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateParticipant(Participant participant) async {
    try {
      final bibDoc = await _firestore.collection(_collectionPath)
          .doc(participant.bibNumber).get();
      
      if (bibDoc.exists) {
        await _firestore.collection(_collectionPath)
            .doc(participant.bibNumber)
            .update(ParticipantDto.toJson(participant));
      } else {
        final querySnapshot = await _firestore.collection(_collectionPath)
            .where('firstName', isEqualTo: participant.firstName)
            .where('lastName', isEqualTo: participant.lastName)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          final oldBib = querySnapshot.docs.first.id;
          
          final batch = ParticipantRepositoryHelper.createBibUpdateBatch(
            _firestore,
            _collectionPath,
            oldBib,
            participant
          );
          
          await batch.commit();
        } else {
          await _firestore.collection(_collectionPath)
              .doc(participant.bibNumber)
              .set(ParticipantDto.toJson(participant));
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteParticipant(String bibNumber) async {
    try {
      final docToDelete = await _firestore.collection(_collectionPath).doc(bibNumber).get();
      
      if (!docToDelete.exists) {
        return;
      }
      
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      final participants = querySnapshot.docs
          .map((doc) => ParticipantDto.fromJson(doc.id, doc.data()))
          .toList();
      
      final batch = ParticipantRepositoryHelper.createBibShiftDownBatch(
        _firestore,
        participants,
        _collectionPath,
        bibNumber
      );
      
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
