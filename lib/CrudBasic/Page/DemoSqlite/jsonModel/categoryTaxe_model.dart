class CategoryTaxeModel {
  final int? idCatTaxe;
  final int? id;
  final int? idSousLibelle;
  final String? nomCatTaxe;

  final String? taux_personnel;
  final String? taux_morale;
  final String? periode;
  final String? jourEcheance;
  final String? date_debit;
  final String? date_fin;
  final String? forme_calcul;

  final String? type_taux;

  final String? createdAt;

  CategoryTaxeModel({
    this.idCatTaxe,
    this.id,
    this.idSousLibelle,
    required this.nomCatTaxe,
    this.taux_personnel,
    this.taux_morale,
    this.periode,
    this.jourEcheance,
    this.date_debit,
    this.date_fin,
    this.forme_calcul,
    this.type_taux,
    this.createdAt,
  });

  factory CategoryTaxeModel.fromMap(Map<String, dynamic> json) =>
      CategoryTaxeModel(
        id: json["id"],
        idCatTaxe: json["idCatTaxe"],
        idSousLibelle: json["idSousLibelle"],
        nomCatTaxe: json["nomCatTaxe"],
        taux_personnel: json["taux_personnel"],
        taux_morale: json["taux_morale"],
        periode: json["periode"],
        jourEcheance: json["jourEcheance"],
        date_debit: json["date_debit"],
        date_fin: json["date_fin"],
        forme_calcul: json["forme_calcul"],
        type_taux: json["type_taux"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "idCatTaxe": idCatTaxe,
        "idSousLibelle": idSousLibelle,
        "nomCatTaxe": nomCatTaxe,
        "taux_personnel": taux_personnel,
        "taux_morale": taux_morale,
        "periode": periode,
        "jourEcheance": jourEcheance,
        "date_debit": date_debit,
        "date_fin": date_fin,
        "forme_calcul": forme_calcul,
        "type_taux": type_taux,
        "createdAt": createdAt,
      };
}
