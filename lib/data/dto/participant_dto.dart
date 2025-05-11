import 'package:race_traking_app/model/participant.dart';

class ParticipantDto {

  static Participant fromJson(String id, Map<String, dynamic> json) {
    return Participant(
      bibNumber: id,
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  static Map<String, dynamic> toJson(Participant participant) {
    return {
      'firstName': participant.firstName,
      'lastName': participant.lastName,
      'age': participant.age,
      'gender': participant.gender,
    };
  }
  
} 