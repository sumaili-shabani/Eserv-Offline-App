import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/TextFildComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/categoryTaxe_model.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddNomaclature extends StatefulWidget {
  AddNomaclature({
    this.noteId,
    this.id,
    this.nomCatTaxe,
    this.taux_personnel,
    this.taux_morale,
    this.periode,
    this.jourEcheance,
    this.date_debit,
    this.date_fin,
    this.forme_calcul,
    this.type_taux,
  });
  final int? noteId;
  final int? id;
  final String? nomCatTaxe;
  final String? taux_personnel;
  final String? taux_morale;
  final String? periode;
  final String? jourEcheance;
  final String? date_debit;
  final String? date_fin;
  final String? forme_calcul;

  final String? type_taux;

  @override
  State<AddNomaclature> createState() => _AddNomaclatureState();
}

class _AddNomaclatureState extends State<AddNomaclature> {
  final nomCatTaxe = TextEditingController();
  final taux_personnel = TextEditingController();
  final taux_morale = TextEditingController();
  final periode = TextEditingController();
  final jourEcheance = TextEditingController();
  final date_debit = TextEditingController();
  final date_fin = TextEditingController();
  final forme_calcul = TextEditingController();
  final type_taux = TextEditingController();
  final code = TextEditingController();
  final id = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ignore: non_constant_identifier_names, prefer_interpolation_to_compose_strings
  String CodeRandom = 'ref-${Random().nextInt(1000000)}';
  String toDay = '${DateFormat("yyyy-MM-dd hh:mm")}';

  final db = DatabaseHelper();
  late DatabaseHelper handler;

  bool editMode = false;

  @override
  void initState() {
    super.initState();

    handler = DatabaseHelper();

    if (widget.noteId != null) {
      editMode = true;
      nomCatTaxe.text = widget.nomCatTaxe.toString();
      taux_personnel.text = widget.taux_personnel.toString();
      taux_morale.text = widget.taux_morale.toString();
      periode.text = widget.periode.toString();
      jourEcheance.text = widget.jourEcheance.toString();
      date_debit.text = widget.date_debit.toString();
      date_fin.text = widget.date_fin.toString();
      forme_calcul.text = widget.forme_calcul.toString();
      type_taux.text = widget.type_taux.toString();
      id.text = widget.id.toString();
    } else {
      code.text = CodeRandom.toString();
    }
  }

  inserOrUpdateData() {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
        db
            .updateCatTaxe(
                nomCatTaxe.text,
                taux_personnel.text,
                taux_morale.text,
                periode.text,
                jourEcheance.text,
                date_debit.text,
                date_fin.text,
                forme_calcul.text,
                type_taux.text,
                int.parse(id.text),
                widget.noteId)
            .whenComplete(() {
          //After update, note will refresh

          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Modification avec succès!!!");
        });
      } else {
        db
            .createCatTaxe(CategoryTaxeModel(
          idSousLibelle: 15,
          nomCatTaxe: nomCatTaxe.text,
          taux_personnel: taux_personnel.text,
          taux_morale: taux_morale.text,
          periode: periode.text,
          jourEcheance: jourEcheance.text,
          date_debit: date_debit.text,
          date_fin: date_fin.text,
          forme_calcul: forme_calcul.text,
          type_taux: type_taux.text,
        ))
            .whenComplete(() {
          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Insertion avec succès!!!");
        });
      }
    }
  }

  // synchronisation
  Future insertUserToOfflineApp() async {
    try {
      handler.getTaxeOnLineApp().whenComplete(() {
        //When this value is true
        Navigator.of(context).pop(true);
        CallApi.showMsg("Les utilisateurs sont bien importés avec succès!!!");
      });
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: editMode
            ? const Text("Modification ")
            : const Text("Enregistrement"),
        actions: [
          IconButton(
            onPressed: () async {
              await handler.isInternet().then((connection) {
                if (connection) {
                  insertUserToOfflineApp();
                  print("Internet connection abailale");
                } else {
                  CallApi.showErrorMsg("Pas de connexion internet");
                }
              });
            },
            icon: const Icon(Icons.person_add),
            color: ConfigurationApp.blackColor,
            tooltip: "Importer les utilisateurs en ligne ",
          ),
          IconButton(
            onPressed: () {
              //Add Note button
              //We should not allow empty data to the database
              inserOrUpdateData();
            },
            icon: editMode ? const Icon(Icons.check) : const Icon(Icons.save),
            tooltip: editMode ? " Modifier les données" : "Ajouter les données",
          ),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 15,
              foregroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
        ],
      ),
      body: Scaffold(
        body: ListView(
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[
            const LayoutHeader(
                title: "Formulaire Catégories de Taxes",
                subTitle:
                    "Cliquer sur un bouton afin d'effectuer une opération!!!"),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    //formulaire
                    TextFildComponent(
                      labeltext: "Designation de la de cat taxe",
                      hint: "Entrez Designation de la de cat taxe",
                      icon: Icons.travel_explore_outlined,
                      controller: nomCatTaxe,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                        labeltext: "Taux personne morale",
                        hint: "Entrez le Taux personne morale",
                        icon: Icons.percent,
                        controller: taux_morale,
                        validatorInput: true),
                    TextFildComponent(
                        labeltext: "Taux personne physique",
                        hint: "Entrez le Taux personne physique",
                        icon: Icons.percent,
                        controller: taux_personnel,
                        validatorInput: true),
                    TextFildComponent(
                        labeltext: "Période",
                        hint: "Entrez la période",
                        icon: Icons.calendar_month,
                        controller: periode,
                        validatorInput: true),
                    TextFildComponent(
                      labeltext: "Jour d'écheance",
                      hint: "Entrez le Jour d'écheance",
                      icon: Icons.event,
                      controller: jourEcheance,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                      labeltext: "Date debit",
                      hint: "Entrez le Date debit",
                      icon: Icons.calendar_today,
                      controller: date_debit,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                      labeltext: "Date fin",
                      hint: "Entrez le Date fin",
                      icon: Icons.calendar_today,
                      controller: date_fin,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                      labeltext: "Forme de calcul",
                      hint: "Entrez le Forme de calcul",
                      icon: Icons.calculate,
                      controller: forme_calcul,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                      labeltext: "Type de taux",
                      hint: "Entrez le Type de taux",
                      icon: Icons.tab,
                      controller: type_taux,
                      validatorInput: true,
                    ),

                    editMode
                        ? TextFildComponent(
                            labeltext: "Identifiant de la cat de taxe",
                            hint: "Id cat de taxe",
                            icon: Icons.edit_note,
                            controller: id,
                            validatorInput: true,
                          )
                        : const Text(''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
