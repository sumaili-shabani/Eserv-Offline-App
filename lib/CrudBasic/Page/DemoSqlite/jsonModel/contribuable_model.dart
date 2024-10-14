class ContribuableModel {
  final int? id;
  final String? typeCb;
  final int? idtypeCb;
  final String? nomCompletCb;
  final String? telCb;
  final String? telsmsCb;
  final String? sexeCb;
  final String? imageCb;
  final String? nomEts;
  final String? respoEts;
  final int? idAvenue;
  final String? numeroMaisonCb;
  final String? codeCb;
  final int? etatCb;
  final String? createdAt;

  ContribuableModel({
    this.id,
    required this.typeCb,
    this.idtypeCb,
    required this.nomCompletCb,
    required this.telCb,
    required this.telsmsCb,
    required this.sexeCb,
    this.imageCb,
    required this.nomEts,
    required this.respoEts,
    required this.idAvenue,
    required this.numeroMaisonCb,
    required this.codeCb,
    this.etatCb,
    this.createdAt,
  });

  factory ContribuableModel.fromMap(Map<String, dynamic> json) =>
      ContribuableModel(
        id: json["id"],
        typeCb: json["typeCb"],
        idtypeCb: json["idtypeCb"],
        nomCompletCb: json["nomCompletCb"],
        telCb: json["telCb"],
        telsmsCb: json["telsmsCb"],
        sexeCb: json["sexeCb"],
        imageCb: json["imageCb"],
        nomEts: json["nomEts"],
        respoEts: json["respoEts"],
        idAvenue: json["idAvenue"],
        numeroMaisonCb: json["numero_maisonCb"],
        codeCb: json["codeCb"],
        etatCb: json["etatCb"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "typeCb": typeCb,
        "idtypeCb": idtypeCb,
        "nomCompletCb": nomCompletCb,
        "telCb": telCb,
        "telsmsCb": telsmsCb,
        "sexeCb": sexeCb,
        "imageCb": imageCb,
        "nomEts": nomEts,
        "respoEts": respoEts,
        "idAvenue": idAvenue,
        "numero_maisonCb": numeroMaisonCb,
        "codeCb": codeCb,
        "etatCb": etatCb,
        "createdAt": createdAt,
      };
}
