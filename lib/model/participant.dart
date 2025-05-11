class Participant {
  final String bibNumber;
  final String firstName;
  final String lastName;
  final int? age;
  final String? gender;

  const Participant({
    required this.bibNumber,
    required this.firstName,
    required this.lastName,
    this.age,
    this.gender,
  });

  Participant copyWith({
    String? bibNumber,
    String? firstName,
    String? lastName,
    int? age,
    String? gender,
    String? school,
  }) {
    return Participant(
      bibNumber: bibNumber ?? this.bibNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      gender: gender ?? this.gender,

    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Participant &&
      other.bibNumber == bibNumber &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.age == age &&
      other.gender == gender; 

  }

  @override
  int get hashCode => bibNumber.hashCode ^ firstName.hashCode ^ lastName.hashCode ^ age.hashCode ^ gender.hashCode ;

  @override
  String toString() {
    return 'Participant(bibNumber: $bibNumber, firstName: $firstName, lastName: $lastName, age: $age, gender: $gender)';
  }
} 