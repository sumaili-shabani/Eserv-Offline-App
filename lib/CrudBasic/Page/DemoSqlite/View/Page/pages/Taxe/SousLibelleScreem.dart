import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxe/AddImmatriculation.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/immatriculationModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SousLibelleScreem extends StatefulWidget {
  const SousLibelleScreem({super.key});

  @override
  State<SousLibelleScreem> createState() => _SousLibelleScreemState();
}

class _SousLibelleScreemState extends State<SousLibelleScreem> {
  late List UserList;
  late DatabaseHelper handler;
  late Future<List<ImmatriculationModel>> notes;
  final db = DatabaseHelper();

  late Timer timer;

  final idLibelle = TextEditingController();
  final idSousLibelle = TextEditingController();
  final nomSousLibelle = TextEditingController();
  final keyword = TextEditingController();

  Future fetchDataList() async {
    // handler.DropTableIfExistsThenReCreateCattaxe();
    List datas = await handler.fetchDataListImmatriculation();
    setState(() {
      UserList = datas;
    });

    print(UserList);
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

  /*
  *
  *=======================
  * Crud
  *=======================
  *
  */
  Future<List<ImmatriculationModel>> getAllNotes() {
    return handler.getImmatriculations();
  }

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<ImmatriculationModel>> searchNote() {
    return handler.searchImmatriculations(keyword.text);
  }

  //Refresh method
  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
      fetchDataList();
    });
  }

  updateData(int? idLibelle, int? idSousLibelle, String? nomSousLibelle,
      int? idImmatriculation) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddImmatriculation(
                  idLibelle: idLibelle,
                  idSousLibelle: idSousLibelle,
                  nomSousLibelle: nomSousLibelle,
                  idImmatriculation: idImmatriculation,
                ))).then((value) {
      if (value) {
        //This will be called
        _refresh();
      }
    });
  }

  deleteData(int noteId) {
    db.deleteImmatriculation(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refresh();
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = handler.getImmatriculations();

    handler.initDB().whenComplete(() {
      notes = getAllNotes();
    });
    super.initState();

    // autre
    fetchDataList();
    isInteret();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        timer.cancel();
      }
    });
    // fin
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddImmatriculation())).then((value) {
              if (value) {
                //This will be called
                _refresh();
              }
            });
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            const LayoutHeader(
                title: 'Immatriculation',
                subTitle:
                    "Liste d'Immatriculation utlisable au système hors connexion"),
            //rechercher component
            Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(0, 5),
                          color: Theme.of(context).primaryColor.withOpacity(.2),
                          spreadRadius: 2,
                          blurRadius: 5)
                    ]),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: keyword,
                        onChanged: (value) {
                          //When we type something in textfield
                          if (value.isNotEmpty) {
                            setState(() {
                              notes = searchNote();
                            });
                          } else {
                            setState(() {
                              notes = getAllNotes();
                            });
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Recherche...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle),
                      child: const Row(
                        children: [
                          Row(
                            children: [
                              Center(
                                  child: Icon(Icons.search,
                                      color: Colors.white, size: 22)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // fin rechercher component

            //list data

            //table
            Expanded(
              child: FutureBuilder<List<ImmatriculationModel>>(
                future: notes,
                builder: (BuildContext context,
                    AsyncSnapshot<List<ImmatriculationModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("No data"));
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    final items = snapshot.data ?? <ImmatriculationModel>[];

                    return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Transform.translate(
                            offset: const Offset(0, -15),
                            child: buildDataCard(context, items[index]),
                          );
                        });
                  }
                },
              ),
            ),
            //list de table
          ],
        ));
  }

  // Helper method to build a note card
  Widget buildDataCard(BuildContext context, ImmatriculationModel note) {
    return Card(
        color: ConfigurationApp.whiteColor,
        child: GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: const CircleAvatar(
                backgroundColor: ConfigurationApp.successColor,
                child: Icon(
                  Icons.description,
                  color: ConfigurationApp.whiteColor,
                )),
            title: Text(note.nomSousLibelle ?? "",
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            subtitle: Text(
              'Péage route',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Wrap(
              children: [
                IconButton(
                    onPressed: () {
                      updateData(
                        note.idLibelle,
                        note.idSousLibelle,
                        note.nomSousLibelle,
                        note.idImmatriculation,
                      );
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: ConfigurationApp.successColor,
                    )),
                IconButton(
                    onPressed: () {
                      deleteData(note.idImmatriculation!);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
              ],
            ),
          ),
        ));
  }

  //fin card
}
