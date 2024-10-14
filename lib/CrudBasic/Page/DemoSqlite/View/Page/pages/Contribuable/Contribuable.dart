import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator_recu.dart';
// import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/DbHelper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Contribuable/create_contribuable.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/DetailTaxation/detailTaxation.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxation/AddTaxation.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/Taxation_model.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/contribuable_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/detailTaxation_model.dart';

import 'package:flutter/material.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

//impression importation
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/invoice.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContribuablePage extends StatefulWidget {
  const ContribuablePage({super.key});

  @override
  State<ContribuablePage> createState() => _ContribuablePageState();
}

class _ContribuablePageState extends State<ContribuablePage> {
  late DatabaseHelper handler;
  late Future<List<ContribuableModel>> notes;
  late Future<List> datas;

  final db = DatabaseHelper();

  final keyword = TextEditingController();
  final keyword2 = TextEditingController();

  late Timer timer;
  String connected = "";

  final PdfGenerator pdfGenerator = PdfGenerator();
  final PdfGeneratorRecu pdfGeneratorRecu = PdfGeneratorRecu();

  /*
  *
  *=========================
  * Crud methodes
  *=========================
  */

  // Crud

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<ContribuableModel>> searchData() {
    return handler.searchCb(keyword.text);
  }

  //Refresh method
  Future<void> refreshData() async {
    setState(() {
      notes = getAllNotes();
      userList();
    });
  }

  deleteData(int id) {
    db.deleteCb(id).whenComplete(() {
      //After success delete , refresh notes
      refreshData();
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  updateData(int id, String nomCompletCb, String typeCb, String codeCb) {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => CreateNote(
    //               title: title,
    //               content: description,
    //               code: code,
    //               noteId: noteId,
    //             )));
  }

/*
  *
  *=========================
  * Synchronisation
  *=========================
  */

  late List listData = [];
  bool loading = true;
  Future userList() async {
    listData = await handler.fetchDataListCb();
    setState(() {
      loading = false;
    });
    // print(listData);
  }

  Future syncToMysql() async {
    await handler.fetchAllInfoCb().then((infoDataList) async {
      EasyLoading.show(
          status: "Ne fermez pas l'application. nous sommes synchronisés...");
      userList();
      // envoie des données au serveur en ligne
      await handler.saveToMysqlCb(listData);

      EasyLoading.showSuccess("Sauvegarde réussie sur la BD online");
      setState(() {
        refreshData();
      });
    });
  }

  getInfoConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('fullNameConnected')!;
    });
  }

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = handler.getCb();

    handler.initDB().whenComplete(() {
      notes = getAllNotes();
    });
    super.initState();

    userList();

    // isInteret();

    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        timer.cancel();
      }
    });
    // fin

    //session
    getInfoConnected();
    // fin session
  }

  Future isInteret() async {
    await handler.isInternet().then((connection) {
      if (connection) {
        print("Internet connection abailale");
        CallApi.showMsg("Prière de synchroniser les données!!!!");
      } else {
        CallApi.showErrorMsg(
            "Pas de connexion d'internet detectée dans ce device!!!!!");
        print("No internet");
      }
    });
  }

  Future<List<ContribuableModel>> getAllNotes() {
    return handler.getCb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //We need call refresh method after a new note is created
            //Now it works properly
            //We will do delete now
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateContribuable()))
                .then((value) {
              if (value) {
                //This will be called
                refreshData();
              }
            });
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            const LayoutHeader(
                title: "Contribuable",
                subTitle: "Liste des contribuables  au système hors connexion"),
            //rechercher component

            // fin rechercher component

            //Search Field here
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.2),
                  borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                controller: keyword,
                onChanged: (value) {
                  //When we type something in textfield
                  if (value.isNotEmpty) {
                    setState(() {
                      notes = searchData();
                    });
                  } else {
                    setState(() {
                      notes = getAllNotes();
                    });
                  }
                },
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                    hintText: "Recherche"),
              ),
            ),
            const SizedBox(
              height: 10,
            ),

            //fin recherche

            //Search Field here
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10),
            //   margin: const EdgeInsets.symmetric(horizontal: 10),
            //   decoration: BoxDecoration(
            //       color: Colors.grey.withOpacity(.2),
            //       borderRadius: BorderRadius.circular(8)),
            //   child: TextFormField(
            //     controller: keyword,
            //     onChanged: (value) {
            //       //When we type something in textfield
            //       if (value.isNotEmpty) {
            //         setState(() {
            //           notes = searchData();
            //         });
            //       } else {
            //         setState(() {
            //           notes = getAllNotes();
            //         });
            //       }
            //     },
            //     decoration: const InputDecoration(
            //         border: InputBorder.none,
            //         icon: Icon(Icons.search),
            //         hintText: "Recherche"),
            //   ),
            // ),

            // debit
            // voir le qrcode
            // const QrcodeGenerateImage(text: "Roger-1234567890", size: 150.0),

            // fin

            Expanded(
              child: FutureBuilder<List<ContribuableModel>>(
                future: notes,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ContribuableModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("No data"));
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    final items = snapshot.data ?? <ContribuableModel>[];

                    return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Transform.translate(
                            offset: const Offset(0, -5),
                            child: buildNoteCard(context, items[index]),
                          );
                        });
                  }
                },
              ),
            ),
          ],
        ));
  }

  // Helper method to build a note card
  Widget buildNoteCard(BuildContext context, ContribuableModel note) {
    return Card(
      child: GestureDetector(
        onTap: () {
          fetchDataListCbSigle(note.id!).whenComplete(() => _showForm(note.id));
        },
        child: ListTile(
          leading: note.etatCb == 0
              ? note.idtypeCb == 1
                  ? const Icon(
                      Icons.person,
                      color: Colors.orange,
                    )
                  : const Icon(
                      Icons.home,
                      color: Colors.green,
                    )
              : const Icon(
                  Icons.check_box_outlined,
                  color: Colors.green,
                ),
          title: note.idtypeCb == 1
              ? Text(
                  note.nomCompletCb ??
                      '/${note.idtypeCb == 1 ? note.typeCb : ""}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : Text(
                  note.nomEts ?? '/${note.idtypeCb == 1 ? note.typeCb : ""}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  note.idtypeCb == 1
                      ? 'Catégorie ${note.typeCb} / ${note.codeCb} '
                      : 'CEO: ${note.respoEts} / ${note.codeCb} ',
                  style: const TextStyle(),
                ),
                Text(
                    'Créée le ${DateFormat("d/M/y").format(DateTime.parse(note.createdAt.toString()))}'),
              ],
            ),
          ),
          trailing: Wrap(
            children: [
              //Modification
              note.etatCb == 0
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateContribuable(
                                      codeCb: note.codeCb,
                                      typeCb: note.typeCb,
                                      idtypeCb: note.idtypeCb,
                                      nomCompletCb: note.nomCompletCb,
                                      telCb: note.telCb,
                                      telsmsCb: note.telsmsCb,
                                      sexeCb: note.sexeCb,
                                      imageCb: note.imageCb,
                                      nomEts: note.nomEts,
                                      respoEts: note.respoEts,
                                      idAvenue: note.idAvenue,
                                      numeroMaisonCb: note.numeroMaisonCb,
                                      etatCb: note.etatCb,
                                      createdAt: note.createdAt,
                                      id: note.id!,
                                    ))).then((value) {
                          if (value) {
                            //This will be called
                            refreshData();
                          }
                        });
                        refreshData();
                      },
                      icon: const Icon(Icons.edit),
                    )
                  : IconButton(
                      onPressed: () {
                        return;
                      },
                      icon: const Icon(
                        Icons.remove_red_eye_outlined,
                      ),
                    ),

              note.etatCb == 0
                  ? IconButton(
                      onPressed: () {
                        // ignore: void_checks
                        deleteData(note.id!);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 255, 81, 0),
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        fetchDataListCbSigle(note.id!)
                            .whenComplete(() => _showForm(note.id));
                      },
                      icon: const Icon(
                        Icons.sync_alt_sharp,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

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
  final idCb = TextEditingController();

  late int idtypeCb = 1;

  List cbdataList = [];
  Future fetchDataListCb() async {
    cbdataList = await handler.fetchDataListAllCb();
    setState(() {
      loading = false;
    });
    print(cbdataList);
  }

  List cbdataListSigle = [];
  Future fetchDataListCbSigle(int id) async {
    List myListSigle = await handler.fetchDataListAllCbSigle(id);
    setState(() {
      cbdataListSigle = myListSigle;
      loading = false;
    });

    // print(cbdataListSigle);
  }

  Future<void> updateDataContribuable(int id) async {
    final int recordIdToDelete = id;
    db
        .updateCbPartie2(nomCompletCb.text, telCb.text, telsmsCb.text,
            nomEts.text, respoEts.text, numeroMaisonCb.text, recordIdToDelete)
        .whenComplete(() {
      CallApi.showMsg("Modification avec succès!!!");
      refreshData();
    });
  }

  // showw form edit
  void _showForm(int? id) async {
    fetchDataListCbSigle(id!);
    for (var i = 0; i < cbdataListSigle.length; i++) {
      String nomCompletCb1 = cbdataListSigle[i]['nomCompletCb'].toString();
      String telsmsCb1 = cbdataListSigle[i]['telsmsCb'].toString();
      String telCb1 = cbdataListSigle[i]['telCb'].toString();
      String nomEts1 = cbdataListSigle[i]['nomEts'].toString();
      String numeroMaisonCb1 = cbdataListSigle[i]['numero_maisonCb'].toString();
      String sexeCb1 = cbdataListSigle[i]['sexeCb'].toString();
      String respoEts1 = cbdataListSigle[i]['respoEts'].toString();
      String idCb1 = cbdataListSigle[i]['id'].toString();

      // print(nomCompletCb1);
      setState(() {
        nomCompletCb.text = nomCompletCb1.toString();
        telsmsCb.text = telsmsCb1.toString();
        telCb.text = telCb1.toString();
        nomEts.text = nomEts1.toString();
        numeroMaisonCb.text = numeroMaisonCb1.toString();
        respoEts.text = respoEts1.toString();
        idtypeCb = cbdataListSigle[i]['idtypeCb'];
        sexeCb.text = sexeCb1.toString();
        idCb.text = idCb1.toString();
      });
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // debit

                    // fin
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Détail du contribuable!',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),

                        //les composants commencent ici
                        TextButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('Fermer'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    idtypeCb == 1
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 15,
                                  ),
                                  Text(
                                      'Nom du contribuable: ${nomCompletCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.man,
                                    size: 15,
                                  ),
                                  Text('Genre de sexe: ${sexeCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 15,
                                  ),
                                  Text('N° téléphone: ${telCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.message,
                                    size: 15,
                                  ),
                                  Text('N° téléphone SMS: ${telsmsCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                    size: 15,
                                  ),
                                  Text(
                                      'Adresse domicile: ${numeroMaisonCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.home_filled,
                                    size: 15,
                                  ),
                                  Text(
                                      'Nom de l\'Etablisement: ${nomEts.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_2,
                                    size: 15,
                                  ),
                                  Text(
                                      'Responsable de l\'Etablisement: ${respoEts.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.man,
                                    size: 15,
                                  ),
                                  Text('Sexe du responsable: ${sexeCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 15,
                                  ),
                                  Text('N° téléphone: ${telCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.message,
                                    size: 15,
                                  ),
                                  Text('N° téléphone SMS: ${telsmsCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                    size: 15,
                                  ),
                                  Text(
                                      'Adresse domicile: ${numeroMaisonCb.text}'),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                              ),
                            ],
                          ),

                    // debit
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Synchronisation"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {},
                                  child: const Text('En ligne'),
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 13,
                                    color: ConfigurationApp.successColor),
                              ],
                            )
                          ]),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 100,
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Card(
                              color: ConfigurationApp.dangerColor,
                              child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddTaxation(
                                                  idCb: int.parse(
                                                      idCb.text.toString()),
                                                )));
                                  },
                                  icon: const Icon(
                                    Icons.note_add,
                                    color: ConfigurationApp.whiteColor,
                                    size: 40,
                                  ),
                                  label: const Text(
                                    "Passer à la taxation",
                                    style: TextStyle(
                                        color: ConfigurationApp.whiteColor),
                                    maxLines: 2,
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Card(
                                color: ConfigurationApp.successColor,
                                child: TextButton.icon(
                                    onPressed: () async {
                                      dataNotes2 = await getAllNotesTaxation(
                                          int.parse(idCb.text));
                                      _refreshTaxation(int.parse(idCb.text))
                                          .whenComplete(() {
                                        setState(() {
                                          notes2 = dataNotes2;
                                        });
                                        _showListTaxation(id);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.note,
                                      size: 40,
                                      color: ConfigurationApp.whiteColor,
                                    ),
                                    label: const Text(
                                      "Savoir plus sur la taxation",
                                      maxLines: 2,
                                      style: TextStyle(
                                          color: ConfigurationApp.whiteColor),
                                    ))),
                          ),
                        ],
                      ),
                    )
                    // fin
                  ],
                ),
              ),
            ));
  }

  // fin show form id

  /*
  *
  *===========================
  * Script pour la taxation
  *===========================
  *
  */
  late List<TaxationModel> notes2;
  late List<TaxationModel> dataNotes2;

  Future getAllNotesTaxation(int idCb) async {
    return await handler.fetchTaxationCb(idCb);
  }

  //Search method here
  Future searchNoteTaxation(int idCb) async {
    return handler.searchTaxationsCb(keyword2.text, idCb);
  }

  /*
    *
    *===========================
    * Script pour la taxation
    *===========================
    *
    */

  //Refresh method
  Future<void> _refreshTaxation(int idCb) async {
    dataNotes2 = await getAllNotesTaxation(idCb);
    setState(() {
      notes2 = dataNotes2;
    });

    // print(notes2);
  }

  // showw form edit
  void _showListTaxation(int? id) async {
    fetchDataListCbSigle(id!);
    for (var i = 0; i < cbdataListSigle.length; i++) {
      String nomCompletCb1 = cbdataListSigle[i]['nomCompletCb'].toString();
      String telsmsCb1 = cbdataListSigle[i]['telsmsCb'].toString();
      String telCb1 = cbdataListSigle[i]['telCb'].toString();
      String nomEts1 = cbdataListSigle[i]['nomEts'].toString();
      String numeroMaisonCb1 = cbdataListSigle[i]['numero_maisonCb'].toString();
      String sexeCb1 = cbdataListSigle[i]['sexeCb'].toString();
      String respoEts1 = cbdataListSigle[i]['respoEts'].toString();
      String idCb1 = cbdataListSigle[i]['id'].toString();

      // print(nomCompletCb1);
      setState(() {
        nomCompletCb.text = nomCompletCb1.toString();
        telsmsCb.text = telsmsCb1.toString();
        telCb.text = telCb1.toString();
        nomEts.text = nomEts1.toString();
        numeroMaisonCb.text = numeroMaisonCb1.toString();
        respoEts.text = respoEts1.toString();
        idtypeCb = cbdataListSigle[i]['idtypeCb'];
        sexeCb.text = sexeCb1.toString();
        idCb.text = idCb1.toString();
      });
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 1,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //les composants commencent ici
                        TextButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('Fermer'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            dataNotes2 =
                                await getAllNotesTaxation(int.parse(idCb.text));
                            setState(() {
                              notes2 = dataNotes2;
                            });
                          },
                          label: const Text("Actualiser"),
                          icon: const Icon(Icons.refresh),
                        )
                      ],
                    ),
                    // debit

                    //Search Field here
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.2),
                          borderRadius: BorderRadius.circular(8)),
                      child: TextFormField(
                        controller: keyword2,
                        onChanged: (value) async {
                          //When we type something in textfield
                          if (value.isNotEmpty) {
                            dataNotes2 =
                                await searchNoteTaxation(int.parse(idCb.text));
                            setState(() {
                              notes2 = dataNotes2;
                            });
                            // print(notes2);
                          } else {
                            dataNotes2 =
                                await getAllNotesTaxation(int.parse(idCb.text));
                            setState(() {
                              notes2 = dataNotes2;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                            hintText: "Recherche"),
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    //fin recherche

                    //table

                    //list de table

                    // debit liste
                    Expanded(
                      child: ListView(
                        children: [
                          //statistique

                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.8,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              child: ListView.builder(
                                  itemCount: notes2.length,
                                  itemBuilder: (context, index) {
                                    TaxationModel items = notes2[index];

                                    return buildDataCard(context, items);
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // fin liste
                  ],
                ),
              ),
            ));
  }

  // fin show form id
  deleteDataTaxation(int noteId, int idCb) {
    db.deleteTaxation(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refreshTaxation(idCb);
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  validerStatutNote(BuildContext context, int noteId) {
    showAlertDialog(context, noteId);
  }

  showAlertDialog(BuildContext context, int id) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Annuler"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continuer"),
      onPressed: () {
        updateStatutTaxation(id);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("êtes-vous sûr ?"),
      content:
          const Text("Vous ne pouvez plus encore recupérer ces données!!!"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  updateStatutTaxation(int id) {
    db.updateTaxationStatut(id).whenComplete(() {
      //After success delete , refresh notes
      Navigator.pop(context);
      CallApi.showMsg("La note a été valider avec succès!!!");
    });
  }

  // Helper method to build a note card
  Widget buildDataCard(BuildContext context, TaxationModel note) {
    return Card(
        color: ConfigurationApp.whiteColor,
        child: GestureDetector(
          child: ListTile(
            title: note.idtypeCb == 1
                ? Text(
                    note.nomCompletCb ??
                        '/${note.idtypeCb == 1 ? note.typeCb : ""}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : Text(
                    note.nomEts ?? '/${note.idtypeCb == 1 ? note.typeCb : ""}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.qr_code,
                      size: 12,
                    ),
                    Text(
                      note.codeNote ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.save,
                      size: 12,
                    ),
                    Text(
                        'le ${DateFormat("d/M/y").format(DateTime.parse(note.dateTaxation.toString()))}'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 12,
                        ),
                        Text('à la date '),
                      ],
                    ),
                    Text(
                        'du ${DateFormat("d/M/y").format(DateTime.parse(note.dateTaxation.toString()))}'),
                  ],
                ),
              ],
            ),
            trailing: Wrap(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    note.statut == 0
                        ? IconButton(
                            tooltip: "Valider la note",
                            onPressed: () async {
                              validerStatutNote(context, note.idTaxation!);
                            },
                            icon: const Icon(
                              Icons.check_box,
                            ))
                        : CircleAvatar(
                            backgroundColor: ConfigurationApp.successColor,
                            child: CircleAvatar(
                                backgroundColor: ConfigurationApp.successColor,
                                child: note.etatNoteSync == 0
                                    ? note.idtypeCb == 1
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Icons.home,
                                            color: Colors.white,
                                          )
                                    : const Icon(
                                        Icons.check_box_outlined,
                                        color: Colors.white,
                                      ))),
                    Text('Devise: ${note.devise}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'A-Fisc: ${note.anneeFiscale}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                //fin coulm devise
                note.statut == 0
                    ? IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailTaxationScrem(
                                        idTaxation: note.idTaxation,
                                        codeNote: note.codeNote,
                                        idUser: note.idUser,
                                      )));
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                        ))
                    : IconButton(
                        onPressed: () {
                          return;
                        },
                        icon: const Icon(
                          Icons.check,
                        )),

                note.etatNoteSync == 0
                    ? note.statut == 0
                        ? //voir le popup
                        IconButton(
                            onPressed: () {
                              deleteDataTaxation(note.idTaxation!, note.idCb!);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ))
                        :
                        //impression
                        IconButton(
                            onPressed: () {
                              // generatePdfInvoce();
                              generatePdfRecuTaxation(note);
                            },
                            icon: const Icon(
                              Icons.print,
                            ))
                    :
                    //impression
                    IconButton(
                        onPressed: () {
                          generatePdfRecuTaxation(note);
                        },
                        icon: const Icon(
                          Icons.print,
                        ))
              ],
            ),
          ),
        ));
  }

  //fin card

  //fin modal

  //impression
  void generatePdfRecuTaxation(TaxationModel infoTaxation) async {
    List<DetailTaxationModel> detailTaxationList = [];
    List<DetailTaxationModel> liste =
        await handler.fetchDetailTaxation(infoTaxation.idTaxation);

    setState(() {
      detailTaxationList = liste;
    });
    late List<InvoiceItem> listeItem = [];
    String Passager = "";

    for (var i = 0; i < detailTaxationList.length; i++) {
      DetailTaxationModel infoTaxe = detailTaxationList[i];
      listeItem.add(InvoiceItem(
        description: infoTaxe.nomCatTaxe.toString(),
        date: DateTime.now(),
        quantity: int.parse(infoTaxe.qte.toString()),
        vat: double.parse(infoTaxe.pu.toString()),
        unitPrice: double.parse(infoTaxe.montantReel.toString()),
      ));
      Passager = infoTaxe.passager.toString();
    }
    // print("cool roger ok: $Passager ");

    final date = DateTime.now();
    final dueDate = date.add(
      const Duration(days: 8),
    );

    final invoice = Invoice(
      supplier: const Supplier(
        name: 'Faysal Neowaz',
        address: 'Dhaka, Bangladesh',
        paymentInfo: 'www.dgrpi.e-serv.org',
      ),
      customer: const Customer(
        name: 'Google',
        address: 'Mountain View, California, United States',
      ),
      info: InvoiceInfo(
        date: date,
        dueDate: dueDate,
        description: 'First Order Invoice',
        number: infoTaxation.codeNote.toString(),
      ),
      items: listeItem,
    );
    final pdfFile = await pdfGeneratorRecu.generateReceiptPdfRecu(
        receiptNumber: infoTaxation.codeNote.toString(),
        date: infoTaxation.dateTaxation.toString(),
        customerName: infoTaxation.nomCompletCb.toString(),
        amount: 99.99,
        invoice: invoice,
        infoTaxation: infoTaxation,
        connected: connected,
        passager: Passager);

    print("Path - ${pdfFile.path}");
    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
    );
  }

  //fin impression
  //impression
  void generatePdfInvoce() async {
    final date = DateTime.now();
    final dueDate = date.add(
      const Duration(days: 7),
    );
    final invoice = Invoice(
      supplier: const Supplier(
        name: 'Faysal Neowaz',
        address: 'Dhaka, Bangladesh',
        paymentInfo: 'https://paypal.me/codespec',
      ),
      customer: const Customer(
        name: 'Google',
        address: 'Mountain View, California, United States',
      ),
      info: InvoiceInfo(
        date: date,
        dueDate: dueDate,
        description: 'First Order Invoice',
        number: '${DateTime.now().year}-9999',
      ),
      items: [
        InvoiceItem(
          description: 'Coffee',
          date: DateTime.now(),
          quantity: 3,
          vat: 0.19,
          unitPrice: 5.99,
        ),
        InvoiceItem(
          description: 'Water',
          date: DateTime.now(),
          quantity: 8,
          vat: 0.19,
          unitPrice: 0.99,
        ),
        InvoiceItem(
          description: 'Orange',
          date: DateTime.now(),
          quantity: 3,
          vat: 0.19,
          unitPrice: 2.99,
        ),
      ],
    );
    final pdfFile = await pdfGenerator.generateReceiptPdf(
        receiptNumber: '12345',
        date: '2024-07-03',
        customerName: 'Sumaili shabani Roger',
        amount: 99.99,
        invoice: invoice);
    // print("Path - ${pdfFile.path}");
    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
    );
  }
  //fin impression
}
