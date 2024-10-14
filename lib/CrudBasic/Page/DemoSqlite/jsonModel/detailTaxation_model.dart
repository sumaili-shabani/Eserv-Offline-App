class DetailTaxationModel {
  final int? id;
  final int? idTaxation;
  final int? idCatTaxe;
  final int? idUser;
  final int? groupeCat;
  final int? idAvenue;
  final String? periode;
  final String? datePeriodeDebit;
  final String? datePeriodeFin;
  final int? pu;
  final int? qte;
  final String? montantCdf;
  final String? montantUsd;
  final int? montantReel;
  final String? commentaire;
  final String? numeroMaison;
  final String? locataire;
  final String? dateContratDebit;
  final String? dateContratFin;
  final String? nbrMois;
  final String? numChassie;
  final String? proprietePlace;
  final String? passager;
  final String? photo;
  final String? codeNote;
  final String? createdAt;
  final String? nomCatTaxe;

  DetailTaxationModel({
    this.id,
    this.idTaxation,
    this.idCatTaxe,
    this.idUser,
    this.groupeCat,
    this.idAvenue,
    this.periode,
    this.datePeriodeDebit,
    this.datePeriodeFin,
    this.pu,
    this.qte,
    this.montantCdf,
    this.montantUsd,
    this.montantReel,
    this.commentaire,
    this.numeroMaison,
    this.locataire,
    this.dateContratDebit,
    this.dateContratFin,
    this.nbrMois,
    this.numChassie,
    this.proprietePlace,
    this.passager,
    this.photo,
    this.codeNote,
    this.nomCatTaxe,
    this.createdAt,
  });

  factory DetailTaxationModel.fromMap(Map<String?, dynamic> json) =>
      DetailTaxationModel(
        id: json["id"],
        idTaxation: json["idTaxation"],
        idCatTaxe: json["idCatTaxe"],
        idUser: json["idUser"],
        groupeCat: json["groupeCat"],
        idAvenue: json["idAvenue"],
        periode: json["periode"],
        datePeriodeDebit: json["date_periode_debit"],
        datePeriodeFin: json["date_periode_fin"],
        pu: json["pu"],
        qte: json["qte"],
        montantCdf: json["montant_cdf"],
        montantUsd: json["montant_usd"],
        montantReel: json["montant_reel"],
        commentaire: json["commentaire"],
        numeroMaison: json["numero_maison"],
        locataire: json["locataire"],
        dateContratDebit: json["dateContrat_debit"],
        dateContratFin: json["dateContrat_fin"],
        nbrMois: json["nbr_mois"],
        numChassie: json["num_chassie"],
        proprietePlace: json["propriete_place"],
        passager: json["passager"],
        photo: json["photo"],
        codeNote: json["codeNote"],
        nomCatTaxe: json["nomCatTaxe"],
        createdAt: json["createdAt"],
      );

  Map<String?, dynamic> toMap() => {
        "id": id,
        "idTaxation": idTaxation,
        "idCatTaxe": idCatTaxe,
        "idUser": idUser,
        "groupeCat": groupeCat,
        "idAvenue": idAvenue,
        "periode": periode,
        "date_periode_debit": datePeriodeDebit,
        "date_periode_fin": datePeriodeFin,
        "pu": pu,
        "qte": qte,
        "montant_cdf": montantCdf,
        "montant_usd": montantUsd,
        "montant_reel": montantReel,
        "commentaire": commentaire,
        "numero_maison": numeroMaison,
        "locataire": locataire,
        "dateContrat_debit": dateContratDebit,
        "dateContrat_fin": dateContratFin,
        "nbr_mois": nbrMois,
        "num_chassie": numChassie,
        "propriete_place": proprietePlace,
        "passager": passager,
        "photo": photo,
        "codeNote": codeNote,
        "nomCatTaxe": nomCatTaxe,
        "createdAt": createdAt,
      };
}
