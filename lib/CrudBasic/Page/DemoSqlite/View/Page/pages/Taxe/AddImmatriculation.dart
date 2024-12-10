import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/TextFildComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/immatriculationModel.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddImmatriculation extends StatefulWidget {
  AddImmatriculation({
    this.idImmatriculation,
    this.idLibelle,
    this.idSousLibelle,
    this.nomSousLibelle,
  });
  final int? idImmatriculation;
  final int? idLibelle;
  final int? idSousLibelle;
  final String? nomSousLibelle;

  @override
  State<AddImmatriculation> createState() => _AddImmatriculationState();
}

class _AddImmatriculationState extends State<AddImmatriculation> {
  final idLibelle = TextEditingController();
  final idSousLibelle = TextEditingController();
  final nomSousLibelle = TextEditingController();
  final idImmatriculation = TextEditingController();

  final code = TextEditingController();

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

    if (widget.idImmatriculation != null) {
      editMode = true;
      idSousLibelle.text = widget.idSousLibelle.toString();
      idLibelle.text = widget.idLibelle.toString();
      nomSousLibelle.text = widget.nomSousLibelle.toString();
    } else {
      code.text = CodeRandom.toString();
      idLibelle.text = "198";
    }
  }

  inserOrUpdateData() {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
        db
            .updateImmatriculation(int.parse(idSousLibelle.text),
                nomSousLibelle.text, widget.idImmatriculation)
            .whenComplete(() {
          //After update, note will refresh

          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Modification avec succès!!!");
        });
      } else {
        db
            .createImmatriculation(ImmatriculationModel(
          idLibelle: int.parse(idLibelle.text),
          idSousLibelle: int.parse(idSousLibelle.text),
          nomSousLibelle: nomSousLibelle.text,
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
  Future insertDataToOfflineApp() async {
    try {
      handler.getImmatriculationOnLineApp().whenComplete(() {
        //When this value is true
        Navigator.of(context).pop(true);
        CallApi.showMsg("Les données sont bien importées avec succès!!!");
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
                  insertDataToOfflineApp();
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
                title: "Formulaire d'immatriculation",
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
                      labeltext: "IdLibelle",
                      hint: "Entrez IdLibelle de la taxe",
                      icon: Icons.keyboard_command_key_rounded,
                      controller: idLibelle,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                      labeltext: "Id Sous Libelle",
                      hint: "Entrez Id sous Libelle de la taxe",
                      icon: Icons.keyboard,
                      controller: idSousLibelle,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                        labeltext: "Nom de l'immatriculation",
                        hint: "Entrez la désignation de l'immatriculation",
                        icon: Icons.description,
                        controller: nomSousLibelle,
                        validatorInput: true),
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
