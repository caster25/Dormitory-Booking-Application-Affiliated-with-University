class OwnerProfile {
  String? iduser; // Change from int? to String?
  String? email;
  String? password;
  String? ownerfname;
  String? ownerlname;
  String? numphone;
  String? role;
  String? dormitoryname; // Example additional field

  OwnerProfile({
    this.iduser,
    this.email,
    this.password,
    this.ownerfname,
    this.ownerlname,
    this.numphone,
    this.role,
    this.dormitoryname,
  });

  Map<String, dynamic> toMap() {
    return {
      'iduser': iduser,
      'email': email,
      'ownerfname': ownerfname,
      'ownerlname': ownerlname,
      'numphone': numphone,
      'role': role,
      'dormitoryname': dormitoryname,
    };
  }
}
