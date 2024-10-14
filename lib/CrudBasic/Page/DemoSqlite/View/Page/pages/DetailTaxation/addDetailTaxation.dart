import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/ButtonComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/DateTextFildComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/TextFildComponent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDetailTaxation extends StatefulWidget {
  const AddDetailTaxation(
      {super.key,
      this.noteId,
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
      this.numChassie,
      this.proprietePlace,
      this.photo,
      this.passager,
      this.nbrMois,
      this.codeNote,
      this.locataire,
      this.dateContratDebit,
      this.dateContratFin,
      this.num_chassie});
  final int? noteId;
  final int? idTaxation;
  final int? idCatTaxe;
  final int? idUser;
  final int? groupeCat;
  final int? idAvenue;
  final String? periode;
  final String? datePeriodeDebit;
  final String? datePeriodeFin;
  final String? pu;
  final String? qte;
  final String? montantCdf;
  final String? montantUsd;
  final String? montantReel;
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
  final String? num_chassie;

  @override
  State<AddDetailTaxation> createState() => _AddDetailTaxationState();
}

class _AddDetailTaxationState extends State<AddDetailTaxation> {
  final idTaxation = TextEditingController();
  final idCatTaxe = TextEditingController();
  final idUser = TextEditingController();
  final periode = TextEditingController();
  final datePeriodeDebit = TextEditingController();

  final datePeriodeFin = TextEditingController();
  final pu = TextEditingController();
  final qte = TextEditingController();
  final montantCdf = TextEditingController();
  final montantUsd = TextEditingController();
  final montantReel = TextEditingController();
  final commentaire = TextEditingController();
  final numeroMaison = TextEditingController();
  final locataire = TextEditingController();
  final dateContratDebit = TextEditingController();
  final dateContratFin = TextEditingController();
  final nbrMois = TextEditingController();
  final numChassie = TextEditingController();
  final proprietePlace = TextEditingController();
  final passager = TextEditingController();
  final codeNote = TextEditingController();
  final num_chassie = TextEditingController();

  final formKey = GlobalKey<FormState>();

  int idConnected = 0;

  // ignore: non_constant_identifier_names, prefer_interpolation_to_compose_strings
  String CodeRandom = 'ref-${Random().nextInt(1000000)}';
  String toDay = '${DateFormat("yyyy-MM-dd hh:mm")}';

  final db = DatabaseHelper();
  late DatabaseHelper handler;

  bool editMode = false;

  String? idCatTaxeSelected;

  late List listCatTaxe = [];
  Future fetchDataList() async {
    handler = DatabaseHelper();
    List datas = await handler.fetchDataListCatTaxe();
    setState(() {
      listCatTaxe = datas;
    });
    // print(' Liste cb:  $listCb');
  }

  Future getCatTaxeSelected(int id) async {
    handler = DatabaseHelper();
    List datas = await handler.getCatTaxeSelected(id);
    for (var i = 0; i < datas.length; i++) {
      setState(() {
        periode.text = datas[i]['periode'].toString();
        datePeriodeDebit.text = datas[i]['date_debit'].toString();
        datePeriodeFin.text = datas[i]['date_fin'].toString();
        qte.text = '1';
        pu.text = datas[i]['taux_personnel'].toString();
        montantReel.text = datas[i]['taux_personnel'].toString();
      });
    }

    // print(' Liste cb:  $listCb');
  }

  @override
  void initState() {
    handler = DatabaseHelper();

    super.initState();

    if (widget.noteId != null) {
      editMode = true;
      idCatTaxe.text = widget.idCatTaxe.toString();
      idUser.text = widget.idUser.toString();
      idTaxation.text = widget.idTaxation.toString();
      dateContratDebit.text = widget.dateContratDebit.toString();
      dateContratFin.text = widget.dateContratFin.toString();
      datePeriodeDebit.text = widget.datePeriodeDebit.toString();
      datePeriodeFin.text = widget.datePeriodeFin.toString();
      qte.text = widget.qte.toString();
      pu.text = widget.pu.toString();
      montantCdf.text = widget.montantCdf.toString();
      montantReel.text = widget.montantReel.toString();
      montantUsd.text = widget.montantUsd.toString();
      locataire.text = widget.locataire.toString();
      nbrMois.text = widget.nbrMois.toString();
      passager.text = widget.passager.toString();
      proprietePlace.text = widget.proprietePlace.toString();
      numChassie.text = widget.numChassie.toString();
      codeNote.text = widget.codeNote.toString();
      periode.text = widget.periode.toString();
      idUser.text = widget.idUser.toString();
      commentaire.text = widget.commentaire.toString();
      num_chassie.text = widget.num_chassie.toString();

      //initialisation
      if (idCatTaxe.text != 'null') {
        idCatTaxeSelected = widget.idCatTaxe.toString();
      }

      //fin initialisation
    } else {
      codeNote.text = CodeRandom.toString();
    }

    fetchDataList();
    // fetchDataTaxationList();
    fetchDataDetailTaxationList();
  }

  inserOrUpdateData() async {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
        db
            .updateDetailTaxation(idCatTaxe.text, qte.text, pu.text,
                montantReel.text, widget.noteId)
            .whenComplete(() {
          //After update, note will refresh

          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Modification avec succès!!!");
        });
      } else {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        idConnected = localStorage.getInt('idConnected')!;

        if (passager.text != '' && qte.text != '' && idCatTaxeSelected != '') {
          Map<String, dynamic> svData = {
            'idTaxation': int.parse(widget.idTaxation.toString()),
            'idUser': int.parse(idConnected.toString()),
            'idCatTaxe': idCatTaxe.text,
            'codeNote': widget.codeNote,
            'periode': periode.text.toString(),
            'date_periode_debit': datePeriodeDebit.text.toString(),
            'date_periode_fin': datePeriodeFin.text.toString(),
            'qte': int.parse(qte.text.toString()),
            'pu': int.parse(pu.text.toString()),
            'montant_cdf': montantCdf.text.toString(),
            'montant_usd': montantUsd.text.toString(),
            'montant_reel': int.parse(montantReel.text.toString()),
            'groupeCat': 5,
            'idAvenue': 1,
            'commentaire': commentaire.text.toString(),
            'numero_maison': numeroMaison.text.toString(),
            'locataire': locataire.text,
            'dateContrat_debit': dateContratDebit.text.toString(),
            'dateContrat_fin': dateContratFin.text.toString(),
            'nbr_mois': nbrMois.text.toLowerCase(),
            'propriete_place': proprietePlace.text.toString(),
            'num_chassie': num_chassie.text.toString(),
            'passager': passager.text.toString(),
          };
          db.insertDetailTaxationData(svData).whenComplete(() {
            //When this value is true
            Navigator.of(context).pop(true);
            CallApi.showMsg("Insertion avec succès!!!");
          });
        } else {
          CallApi.showErrorMsg("Veillez compléter tous les champs!!!");
        }
      }
    }
  }

  List TaxationList = [];
  Future fetchDataTaxationList() async {
    List datas = await handler.fetchDataListTaxation();
    setState(() {
      TaxationList = datas;
    });

    // print(TaxationList);
  }

  List detailTaxationList = [];
  Future fetchDataDetailTaxationList() async {
    List datas = await handler.fetchDataListDetailTaxationSendToOnlineApp();
    setState(() {
      detailTaxationList = datas;
    });

    print(detailTaxationList);
  }

  Future syncToMysql() async {
    fetchDataDetailTaxationList();
    // await fetchDataDetailTaxationList();
    // await handler
    //     .fetchDataListDetailTaxation(int.parse(widget.idTaxation.toString()));
    // EasyLoading.show(
    //     status: "Ne fermez pas l'application. nous sommes synchronisés...");

    // envoie des données au serveur en ligne
    // await handler.saveToMysqlTaxation(detailTaxationList).whenComplete(() {
    //   Navigator.of(context).pop(true);
    // });

    await handler
        .saveToMysqlDetailTaxation(detailTaxationList)
        .whenComplete(() {
      Navigator.of(context).pop(true);
    });

    //When this value is true
    // EasyLoading.showSuccess("Sauvegarde réussie sur la BD online");
    setState(() {
      fetchDataDetailTaxationList();
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
          //     onPressed: () {
          //       syncToMysql();
          //     },
          //     icon: const Icon(Icons.payment)),
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
            LayoutHeader(
                title: 'Formulaire Détail Taxation',
                subTitle:
                    "Référence de la note ${widget.idTaxation} - ${widget.codeNote}. Cliquer sur un bouton afin d'effectuer une opération!!!"),
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
                        value: idCatTaxeSelected,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Selectionner la catégorie de taxe"),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: listCatTaxe.map((list) {
                          return DropdownMenuItem(
                            value: list['id'].toString(),
                            child: Text(list['nomCatTaxe']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            idCatTaxeSelected = value.toString();
                            idCatTaxe.text = idCatTaxeSelected.toString();
                            getCatTaxeSelected(int.parse(value.toString()));
                          });
                        },
                      ),
                    ),
                    const Divider(color: Colors.black),
                    TextFildComponent(
                      labeltext: "Période",
                      hint: "Entrez la Période",
                      icon: Icons.edit_note,
                      controller: periode,
                      maxLines: 1,
                    ),
                    //formulaire
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          color: Colors.white10,
                          child: DateTextFildComponent(
                              labeltext: "Période débit ",
                              hint: "Entrez la date de Période fin",
                              icon: Icons.event,
                              controller: datePeriodeDebit,
                              validatorInput: false),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          color: Colors.white10,
                          child: DateTextFildComponent(
                              labeltext: "Période fin ",
                              hint: "Entrez la date de Période fin",
                              icon: Icons.event,
                              controller: datePeriodeFin,
                              validatorInput: false),
                        ),
                      ],
                    ),

                    TextFildComponent(
                      labeltext: "Passager",
                      hint: "Entrez la Période",
                      icon: Icons.person,
                      controller: passager,
                      maxLines: 1,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            color: Colors.white10,
                            child: TextFildComponent(
                              labeltext: "Quantité",
                              hint: "Entrez la quantoté",
                              icon: Icons.format_list_numbered_rounded,
                              controller: qte,
                              maxLines: 1,
                              keyboardTypeNumber: true,
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          color: Colors.white10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  int prix = int.parse(pu.text.toString());
                                  int prixTotal =
                                      prix * int.parse(qte.text.toString());
                                  setState(() {
                                    montantReel.text = prixTotal.toString();
                                  });
                                  print('Prix total: $prixTotal');
                                },
                                label: const Text(""),
                                icon: const Icon(
                                  Icons.calculate,
                                  color: ConfigurationApp.whiteColor,
                                ),
                                style: ElevatedButton.styleFrom(
                                  alignment: const Alignment(1, 1),
                                  backgroundColor:
                                      ConfigurationApp.successColor,
                                  padding: const EdgeInsets.all(10),
                                ),
                              ),
                              const Divider(
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),

                    TextFildComponent(
                      labeltext: "Prix unitaire Usd",
                      hint: "Entrez le Prix unitaire",
                      icon: Icons.payments,
                      controller: pu,
                      maxLines: 1,
                      enabledChamps: false,
                    ),
                    TextFildComponent(
                      labeltext: "Montant Usd",
                      hint: "Entrez le Prix unitaire",
                      icon: Icons.payments,
                      controller: montantReel,
                      maxLines: 1,
                      enabledChamps: false,
                    ),

                    TextFildComponent(
                      labeltext: "Commentaire",
                      hint: "Entrez le Commentaire",
                      icon: Icons.edit_note,
                      controller: commentaire,
                      maxLines: 2,
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
