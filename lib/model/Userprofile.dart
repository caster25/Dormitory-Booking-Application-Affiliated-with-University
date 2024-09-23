class UserProfile {
  String? idusers;
  String? email;
  String? username;
  String? fullname;
  String? numphone;
  String? password;
  String? role;
  String? profilePictureURL;

  UserProfile({
    this.idusers,
    this.email,
    this.username,
    this.fullname,
    this.numphone,
    this.password,
    this.role,
    this.profilePictureURL,
  });

  // Create a UserProfile instance from a Map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      idusers: map['iduser'] as String?,
      email: map['email'] as String?,
      username: map['username'] as String?,
      fullname: map['fullname'] as String?,
      numphone: map['numphone'] as String?,
      role: map['role'] as String?,
      profilePictureURL: map['profilePictureURL'] as String?,
    );
  }

  // Convert UserProfile instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'iduser': idusers,
      'email': email,
      'username': username,
      'fullname': fullname,
      'numphone': numphone,
      'role': role,
      'profilePictureURL': profilePictureURL,
    };
  }
}
