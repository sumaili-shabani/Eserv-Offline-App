import 'dart:async';
import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/DateTextFildComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/TextFildComponent.dart';
// import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/Taxation_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaxation extends StatefulWidget {
  AddTaxation({
    this.noteId,
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
  });
  final int? noteId;
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

  @override
  State<AddTaxation> createState() => _AddTaxationState();
}

class _AddTaxationState extends State<AddTaxation> {
  late Timer _timer;
  final idCb = TextEditingController();
  final idUser = TextEditingController();
  final devise = TextEditingController();
  final anneeFiscale = TextEditingController();
  final codeNote = TextEditingController();
  final comment = TextEditingController();
  final dateTaxation = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late List taxationList;
  int idConnected = 0;

  // ignore: non_constant_identifier_names, prefer_interpolation_to_compose_strings
  String CodeRandom = 'ref-${Random().nextInt(1000000)}';
  String toDay = '${DateFormat("yyyy-MM-dd hh:mm")}';

  final db = DatabaseHelper();
  late DatabaseHelper handler;

  bool editMode = false;
  String? anneeFiscaleSelected;
  String? deviseSelected;
  String? idCbSelected;
  late List anneeFiscaleList = [
    {'designation': '2015'},
    {'designation': '2016'},
    {'designation': '2017'},
    {'designation': '2018'},
    {'designation': '2019'},
    {'designation': '2020'},
    {'designation': '2021'},
    {'designation': '2022'},
    {'designation': '2023'},
    {'designation': '2024'},
    {'designation': '2025'},
    {'designation': '2026'},
    {'designation': '2027'},
    {'designation': '2028'},
    {'designation': '2029'},
    {'designation': '2030'},
  ];
  late List deviseList = [
    {'designation': 'Usd'},
  ];

  late List listCb = [];
  Future getCbList() async {
    handler = DatabaseHelper();
    List datas = await handler.fetchAllDataListCb();
    setState(() {
      listCb = datas;
    });
    // print(' Liste cb:  $listCb');
  }

  @override
  void initState() {
    handler = DatabaseHelper();

    handler.initDB().whenComplete(() {
      getCbList();
    });
    super.initState();

    anneeFiscaleSelected = "${DateTime.now().year}";
    deviseSelected = "Usd";
    devise.text = "Usd";
    anneeFiscale.text = "${DateTime.now().year}";

    if (widget.noteId != null) {
      editMode = true;
      idCb.text = widget.idCb.toString();
      idUser.text = widget.idUser.toString();

      //initialisation
      anneeFiscale.text = widget.anneeFiscale.toString();
      if (anneeFiscale.text != '2024') {
        anneeFiscaleSelected = widget.anneeFiscale.toString();
      }
      if (idCb.text != '') {
        idCbSelected = widget.idCb.toString();
      }
      //fin initialisation
      codeNote.text = widget.codeNote.toString();
      comment.text = widget.comment.toString();
      dateTaxation.text = widget.dateTaxation.toString();
    } else {
      codeNote.text = CodeRandom.toString();
      if (widget.idCb != null) {
        idCbSelected = widget.idCb.toString();
        idCb.text = idCbSelected.toString();
      }
    }

    fetchDataList();

    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer.cancel();
      }
    });
  }

  inserOrUpdateData() async {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
        db
            .updateTaxation(devise.text, anneeFiscale.text, comment.text,
                dateTaxation.text, idCb.text, widget.noteId)
            .whenComplete(() {
          //After update, note will refresh

          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Modification avec succès!!!");
        });
      } else {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        idConnected = localStorage.getInt('idConnected')!;

        Map<String, dynamic> svData = {
          'idCompteBancaire': 1,
          'statut': 0,
          'payementStatut': 0,
          'etatNoteSync': 0,
          'idCb': int.parse(idCb.text),
          'idUser': int.parse(idConnected.toString()),
          'devise': devise.text,
          'anneeFiscale': anneeFiscale.text,
          'codeNote': codeNote.text,
          'dateTaxation': dateTaxation.text,
          'comment': comment.text,
        };
        db.insertTaxationData(svData).whenComplete(() {
          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Insertion avec succès!!!");
        });
      }
    }
  }

  Future fetchDataList() async {
    List datas = await handler.fetchDataListTaxation();
    setState(() {
      taxationList = datas;
    });

    print(taxationList);
  }

  Future syncToMysql() async {
    fetchDataList();
    await handler.fetchDataListTaxation();
    EasyLoading.show(
        status: "Ne fermez pas l'application. nous sommes synchronisés...");

    // envoie des données au serveur en ligne
    await handler.saveToMysqlTaxation(taxationList).whenComplete(() {
      Navigator.of(context).pop(true);
    });

    //When this value is true

    EasyLoading.showSuccess("Sauvegarde réussie sur la BD online");
    setState(() {
      fetchDataList();
    });
  }

  // synchronisation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: editMode
            ? const Text("Modification ")
            : const Text("Enregistrement"),
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     await handler.isInternet().then((connection) {
          //       if (connection) {
          //         syncToMysql();
          //         print("Internet connection abailale");
          //       } else {
          //         CallApi.showErrorMsg("Pas de connexion internet");
          //       }
          //     });
          //   },
          //   icon: const Icon(Icons.refresh_outlined),
          //   color: ConfigurationApp.blackColor,
          //   tooltip: "Importer les utilisateurs en ligne ",
          // ),
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
                title: 'Formulaire Taxation',
                subTitle:
                    "Cliquer sur un bouton afin d'effectuer une opération!!!"),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    //combo box
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: DropdownButton<String>(
                        value: anneeFiscaleSelected ?? "",
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Année fiscale"),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: anneeFiscaleList.map((list) {
                          return DropdownMenuItem(
                            value: list['designation'].toString(),
                            child: Text(list['designation']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            anneeFiscaleSelected = value.toString();
                            anneeFiscale.text = anneeFiscaleSelected.toString();
                          });
                        },
                      ),
                    ),
                    const Divider(color: Colors.black),

                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: DropdownButton<String>(
                        value: deviseSelected ?? "",
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Selectionnez une devise"),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: deviseList.map((list) {
                          return DropdownMenuItem(
                            value: list['designation'].toString(),
                            child: Text(list['designation']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            deviseSelected = value.toString();
                            devise.text = deviseSelected.toString();
                          });
                        },
                      ),
                    ),
                    const Divider(color: Colors.black),

                    // liste de contribuables
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: DropdownButton<String>(
                        value: idCbSelected ?? null,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Selectionnez un contribuable"),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: listCb.map((list) {
                          return DropdownMenuItem(
                            value: list['id'].toString()!,
                            child: Text(
                                '${list["nomCompletCb"]}${list["nomEts"]}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            idCbSelected = value.toString();
                            idCb.text = idCbSelected.toString();
                          });
                        },
                      ),
                    ),
                    const Divider(color: Colors.black),

                    //formulaire
                    DateTextFildComponent(
                        labeltext: "Date de taxation",
                        hint: "Entrez la date de taxation",
                        icon: Icons.event,
                        controller: dateTaxation,
                        validatorInput: true),
                    TextFildComponent(
                      labeltext: "Commentaire",
                      hint: "Entrez le Commentaire",
                      icon: Icons.edit_note,
                      controller: comment,
                      maxLines: 3,
                    ),
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
