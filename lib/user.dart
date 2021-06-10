class User {
  final String firstName;
  final String lastName;
  final int age;

  User({
    required this.firstName,
    required this.lastName,
    required this.age,
  });

  static User? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return User(
      firstName: json["first_name"],
      lastName: json["last_name"],
      age: json["age"],
    );
  }
}
