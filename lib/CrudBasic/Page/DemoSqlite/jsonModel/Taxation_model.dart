class TaxationModel {
  final int? idTaxation;
  final int? idCompteBancaire;
  final int? etatNoteSync;
  final int? idCb;
  final int? idUser;
  final String? devise;
  final String? anneeFiscale;
  final String? codeNote;
  final int? statut;
  final int? payementStatut;
  final String? comment;
  final String? dateTaxation;
  final String? createdAt;
  final String? nomCompletCb;
  final String? nomEts;
  final String? typeCb;
  final int? idtypeCb;

  TaxationModel({
    this.idTaxation,
    this.idCompteBancaire,
    this.etatNoteSync,
    this.idCb,
    this.idUser,
    this.devise,
    this.anneeFiscale,
    this.codeNote,
    this.statut,
    this.payementStatut,
    this.comment,
    this.dateTaxation,
    this.nomCompletCb,
    this.nomEts,
    this.typeCb,
    this.idtypeCb,
    this.createdAt,
  });

  factory TaxationModel.fromMap(Map<String, dynamic> json) => TaxationModel(
        idTaxation: json["idTaxation"],
        idCompteBancaire: json["idCompteBancaire"],
        etatNoteSync: json["etatNoteSync"],
        idCb: json["idCb"],
        idUser: json["idUser"],
        devise: json["devise"],
        anneeFiscale: json["anneeFiscale"],
        codeNote: json["codeNote"],
        statut: json["statut"],
        payementStatut: json["payementStatut"],
        comment: json["comment"],
        nomCompletCb: json["nomCompletCb"],
        nomEts: json["nomEts"],
        dateTaxation: json["dateTaxation"],
        idtypeCb: json["idtypeCb"],
        typeCb: json["typeCb"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "idTaxation": idTaxation,
        "idCompteBancaire": idCompteBancaire,
        "etatNoteSync": etatNoteSync,
        "idCb": idCb,
        "idUser": idUser,
        "devise": devise,
        "anneeFiscale": anneeFiscale,
        "codeNote": codeNote,
        "statut": statut,
        "payementStatut": payementStatut,
        "comment": comment,
        "nomCompletCb": nomCompletCb,
        "nomEts": nomEts,
        "dateTaxation": dateTaxation,
        "idtypeCb": idtypeCb,
        "typeCb": typeCb,
        "createdAt": createdAt,
      };
}
