class PeageModel {
  final int? idPeage;
  final int? idCatTaxe;
  final int? idUser;
  final int? qte;
  final double? pu;
  final double? montantUsd;
  final String? nomAgent;
  final String? nomCb;
  final String? telCb;
  final String? marqueVehicule;
  final String? modelVehicule;
  final String? chassieVehicule;
  final String? numPlaque;
  final String? devise;
  final String? datePaiement;
  final String? codeNote;
  final String? comment;
  final String? nomCatTaxe;
  final String? createdAt;
  final int? statutPeage;

  PeageModel({
    this.idPeage,
    this.idCatTaxe,
    this.idUser,
    this.qte,
    this.pu,
    this.montantUsd,
    this.nomAgent,
    this.nomCb,
    this.telCb,
    this.marqueVehicule,
    this.modelVehicule,
    this.chassieVehicule,
    this.numPlaque,
    this.devise,
    this.datePaiement,
    this.codeNote,
    this.comment,
    this.nomCatTaxe,
    this.createdAt,
    this.statutPeage,
  });

  factory PeageModel.fromMap(Map<String, dynamic> json) => PeageModel(
        idPeage: json["idPeage"],
        idCatTaxe: json["idCatTaxe"],
        idUser: json["idUser"],
        qte: json["qte"],
        pu: json["pu"],
        montantUsd: json["montantUsd"],
        nomAgent: json["nomAgent"],
        nomCb: json["nomCb"],
        telCb: json["telCb"],
        marqueVehicule: json["marqueVehicule"],
        modelVehicule: json["modelVehicule"],
        chassieVehicule: json["chassieVehicule"],
        numPlaque: json["numPlaque"],
        devise: json["devise"],
        datePaiement: json["datePaiement"],
        codeNote: json["codeNote"],
        comment: json["comment"],
        nomCatTaxe: json["nomCatTaxe"],
        createdAt: json["createdAt"],
        statutPeage: json["statutPeage"],
      );

  Map<String, dynamic> toMap() => {
        "idPeage": idPeage,
        "idCatTaxe": idCatTaxe,
        "idUser": idUser,
        "qte": qte,
        "pu": pu,
        "montantUsd": montantUsd,
        "nomAgent": nomAgent,
        "nomCb": nomCb,
        "telCb": telCb,
        "marqueVehicule": marqueVehicule,
        "modelVehicule": modelVehicule,
        "chassieVehicule": chassieVehicule,
        "numPlaque": numPlaque,
        "devise": devise,
        "datePaiement": datePaiement,
        "codeNote": codeNote,
        "comment": comment,
        "nomCatTaxe": nomCatTaxe,
        "createdAt": createdAt,
        "statutPeage": statutPeage,
      };
}
