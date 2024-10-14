import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Components/button.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Components/textfield.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/TextFildComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/contribuable_model.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateContribuable extends StatefulWidget {
  const CreateContribuable(
      {super.key,
      this.typeCb,
      this.idtypeCb,
      this.nomCompletCb,
      this.telCb,
      this.telsmsCb,
      this.sexeCb,
      this.imageCb,
      this.nomEts,
      this.respoEts,
      this.idAvenue,
      this.numeroMaisonCb,
      this.id,
      this.codeCb,
      this.etatCb,
      this.createdAt});
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
  @override
  State<CreateContribuable> createState() => _CreateContribuableState();
}

class _CreateContribuableState extends State<CreateContribuable> {
  final typeCb = TextEditingController();

  final nomCompletCb = TextEditingController();
  final telCb = TextEditingController();
  final telsmsCb = TextEditingController();
  final sexeCb = TextEditingController();
  final imageCb = TextEditingController();
  final nomEts = TextEditingController();
  final respoEts = TextEditingController();
  final idAvenue = TextEditingController();
  final numeroMaisonCb = TextEditingController();
  final codeCb = TextEditingController();
  final etatCb = TextEditingController();
  final createdAt = TextEditingController();
  late int idtypeCb = 1;

  late int idtypeCbValue;
  String? selectedtypeCbValue;

  final formKey = GlobalKey<FormState>();

  late List typeCbList = [
    {'id': 1, 'designation': 'Personne Physique'},
    {'id': 2, 'designation': 'Personne Morale'}
  ];
  late List sexeCbList = [
    {'id': 1, 'designation': 'M'},
    {'id': 2, 'designation': 'F'}
  ];

  String? selectedSexeCbValue;

  // ignore: non_constant_identifier_names, prefer_interpolation_to_compose_strings
  String CodeRandom = 'cbm-${Random().nextInt(1000000)}';
  String toDay = '${DateFormat("yyyy-MM-dd hh:mm")}';

  final db = DatabaseHelper();

  bool editMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.id != null) {
      editMode = true;
      typeCb.text = widget.typeCb.toString();
      idtypeCb = int.parse(widget.idtypeCb.toString());
      selectedtypeCbValue = widget.idtypeCb.toString();

      nomCompletCb.text = widget.nomCompletCb.toString();
      telCb.text = widget.telCb.toString();
      telsmsCb.text = widget.telsmsCb.toString();
      selectedSexeCbValue = widget.sexeCb.toString();
      imageCb.text = widget.imageCb.toString();
      nomEts.text = widget.nomEts.toString();
      respoEts.text = widget.respoEts.toString();
      idAvenue.text = widget.idAvenue.toString();
      numeroMaisonCb.text = widget.numeroMaisonCb.toString();
      // etatCb.text = widget.etatCb.toString();
      codeCb.text = widget.codeCb.toString();
    } else {
      codeCb.text = CodeRandom.toString();
      telCb.text = "+243";
      telsmsCb.text = "+243";

      if (typeCb.text == '') {
        selectedtypeCbValue = '1';
        typeCb.text = selectedtypeCbValue.toString();
      }
    }
  }

  inserOrUpdateData() {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
        db
            .updateCb(
                nomCompletCb.text,
                telCb.text,
                telsmsCb.text,
                selectedSexeCbValue.toString(),
                nomEts.text,
                respoEts.text,
                numeroMaisonCb.text,
                widget.id)
            .whenComplete(() {
          //After update, note will refresh

          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Modification avec succès!!!");
        });
      } else {
        if (idtypeCb == 1) {
          setState(() {
            typeCb.text = 'Personne Physique';
          });
        } else {
          setState(() {
            typeCb.text = 'Personne Morale';
          });
        }
        db
            .createCb(ContribuableModel(
                id: null,
                typeCb: typeCb.text,
                nomCompletCb: nomCompletCb.text,
                sexeCb: selectedSexeCbValue,
                telCb: telCb.text,
                telsmsCb: telsmsCb.text,
                codeCb: codeCb.text,
                idAvenue: 1,
                nomEts: nomEts.text,
                numeroMaisonCb: numeroMaisonCb.text,
                respoEts: respoEts.text,
                etatCb: 0,
                imageCb: 'avatar.png',
                idtypeCb: idtypeCb,
                createdAt: DateTime.now().toIso8601String()))
            .whenComplete(() {
          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Insertion avec succès!!!");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConfigurationApp.successColor,
      appBar: AppBar(
        title: editMode
            ? const Text("Modification ")
            : const Text("Enregistrement"),
        actions: [
          IconButton(
              onPressed: () {
                //Add Note button
                //We should not allow empty data to the database
                inserOrUpdateData();
              },
              icon: editMode ? const Icon(Icons.check) : const Icon(Icons.save))
        ],
      ),
      body: Scaffold(
        body: ListView(children: [
          const LayoutHeader(
              title: 'Formulaire Contribuable',
              subTitle:
                  "Cliquer sur un bouton afin d'effectuer une opération!!!"),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(60)),
                  color: Colors.white),
              child: Form(
                  //I forgot to specify key
                  key: formKey,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          //type contribuable
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: DropdownButton<String>(
                              value: selectedtypeCbValue,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: const Text("Type de contribuable"),
                              icon: const Icon(Icons.arrow_drop_down),
                              items: typeCbList.map((list) {
                                return DropdownMenuItem(
                                  value: list['id'].toString(),
                                  child: Text(list['designation']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedtypeCbValue = value.toString();
                                  idtypeCb = int.parse(value.toString());
                                });
                                print('selectedtypeCbValue: $idtypeCb');
                                // print(selectedtypeCbValue);
                              },
                            ),
                          ),
                          const Divider(color: Colors.black),

                          idtypeCb == 2
                              ? Column(
                                  children: [
                                    TextFildComponent(
                                        labeltext: "Nom Etablissement",
                                        hint: "Entrez le nom Etablissement",
                                        icon: Icons.home_filled,
                                        controller: nomEts,
                                        validatorInput: false),
                                    TextFildComponent(
                                        labeltext:
                                            "Responsable de l'Etablissement",
                                        hint:
                                            "Entrez le nom de responsable de l'Etablissement",
                                        icon: Icons.person_2,
                                        controller: respoEts,
                                        validatorInput: false)
                                  ],
                                )
                              : Column(
                                  children: [
                                    TextFildComponent(
                                        labeltext: "Nom de contribuable",
                                        hint: "Entrez le Nom de contribuable",
                                        icon: Icons.person,
                                        controller: idtypeCb == 1
                                            ? nomCompletCb
                                            : nomEts,
                                        validatorInput: true),
                                  ],
                                ),

                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              child: DropdownButton<String>(
                                value: selectedSexeCbValue,
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: idtypeCb == 1
                                    ? const Text("Le sexe du contribuable")
                                    : const Text(
                                        "Le sexe de responsable de l'Ets"),
                                icon: const Icon(Icons.arrow_drop_down),
                                items: sexeCbList.map((list) {
                                  return DropdownMenuItem(
                                    value: list['designation'].toString(),
                                    child: Text(list['designation']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedSexeCbValue = value.toString();
                                  });
                                },
                              ),
                            ),
                          ),
                          const Divider(color: Colors.black),

                          TextFildComponent(
                              labeltext: "N° téléphone Cb",
                              hint: "Entrez N° téléphone Cb",
                              icon: Icons.phone,
                              controller: telCb,
                              validatorInput: true),
                          TextFildComponent(
                              labeltext: "N° de téléphone SMS Cb",
                              hint: "Entrez N° téléphone SMS Cb",
                              icon: Icons.message,
                              controller: telsmsCb,
                              validatorInput: true),

                          TextFildComponent(
                              labeltext: "Adresse et N° de la maison du Cb",
                              hint: "Entrez Adresse et N° de la maison du Cb",
                              icon: Icons.location_city,
                              controller: numeroMaisonCb,
                              validatorInput: false),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ]),
      ),
    );
  }
}
