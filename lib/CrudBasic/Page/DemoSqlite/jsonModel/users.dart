class Users {
  final int? usrId;
  final int? id;
  final int? idRole;
  final String? fullName;
  final String? email;
  final String usrName;
  final String password;

  Users({
    this.usrId,
    this.id,
    this.idRole,
    this.fullName,
    this.email,
    required this.usrName,
    required this.password,
  });

  //These json value must be same as your column name in database that we have already defined
  //one column didn't match
  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        id: json["id"],
        idRole: json["idRole"],
        fullName: json["fullName"],
        email: json["email"],
        usrName: json["usrName"],
        password: json["usrPassword"],
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "id": id,
        "idRole": usrId,
        "fullName": fullName,
        "email": email,
        "usrName": usrName,
        "usrPassword": password,
      };
}
