class UserProfile {
  String? idusers;
  String? email;
  String? username;
  String? fullname;
  String? numphone;
  String? password;
  String? role;
  String? profilePictureURL;
  String? bookedDormitory;
  String? currentDormitoryId;
  List<String> favorites; 
  String? isStaying; 

  UserProfile({
    this.idusers,
    this.email,
    this.username,
    this.fullname,
    this.numphone,
    this.password,
    this.role,
    this.profilePictureURL,
    this.bookedDormitory,
    this.currentDormitoryId,
    List<String>? favorites,
    this.isStaying ,
  }) : favorites = favorites ?? [];

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      idusers: map['iduser'] as String?,
      email: map['email'] as String?,
      username: map['username'] as String?,
      password: map['password'] as String?,
      fullname: map['fullname'] as String?,
      numphone: map['numphone'] as String?,
      role: map['role'] as String?,
      profilePictureURL: map['profilePictureURL'] as String?,
      bookedDormitory: map['bookedDormitory'] as String?,
      currentDormitoryId: map['currentDormitoryId'] as String?,
      favorites: List<String>.from(map['favorites'] ?? []),
      isStaying: map['isStaying'] as String? ,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'iduser': idusers,
      'email': email,
      'username': username,
      'password': password,
      'fullname': fullname,
      'numphone': numphone,
      'role': role,
      'profilePictureURL': profilePictureURL,
      'bookedDormitory': bookedDormitory,
      'currentDormitoryId': currentDormitoryId,
      'favorites': favorites,
      'isStaying': isStaying,
    };
  }
}
