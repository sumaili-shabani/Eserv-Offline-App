class ImmatriculationModel {
  final int? idImmatriculation;
  final int? idLibelle;
  final int? idSousLibelle;
  final String? nomSousLibelle;
  final String? createdAt;

  ImmatriculationModel({
    this.idImmatriculation,
    this.idLibelle,
    this.idSousLibelle,
    this.nomSousLibelle,
    this.createdAt,
  });

  factory ImmatriculationModel.fromMap(Map<String, dynamic> json) =>
      ImmatriculationModel(
        idImmatriculation: json["idImmatriculation"],
        idLibelle: json["idLibelle"],
        idSousLibelle: json["idSousLibelle"],
        nomSousLibelle: json["nomSousLibelle"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "idImmatriculation": idImmatriculation,
        "idLibelle": idLibelle,
        "idSousLibelle": idSousLibelle,
        "nomSousLibelle": nomSousLibelle,
        "createdAt": createdAt,
      };
}
