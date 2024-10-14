import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxe/AddNomaclature.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/categoryTaxe_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class TaxeScreem extends StatefulWidget {
  const TaxeScreem({super.key});

  @override
  State<TaxeScreem> createState() => _TaxeScreemState();
}

class _TaxeScreemState extends State<TaxeScreem> {
  late List UserList;
  late DatabaseHelper handler;
  late Future<List<CategoryTaxeModel>> notes;
  final db = DatabaseHelper();

  late Timer timer;

  final nomController = TextEditingController();
  final keyword = TextEditingController();

  Future fetchDataList() async {
    // handler.DropTableIfExistsThenReCreateCattaxe();
    List datas = await handler.fetchDataListCatTaxe();
    setState(() {
      UserList = datas;
    });

    print(UserList);
  }

  Future insertUserOnLineToOfflineCompte() async {
    List datas = await handler.fetchDataListCatTaxe();
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
  Future<List<CategoryTaxeModel>> getAllNotes() {
    return handler.fetchCatTaxe();
  }

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<CategoryTaxeModel>> searchNote() {
    return handler.searchCategories(keyword.text);
  }

  //Refresh method
  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
      fetchDataList();
    });
  }

  updateData(
      String? nomCatTaxe,
      String? taux_personnel,
      String? taux_morale,
      String? periode,
      String? jourEcheance,
      String? date_debit,
      String? date_fin,
      String? forme_calcul,
      String? type_taux,
      int? id,
      int? idCatTaxe) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddNomaclature(
                  noteId: idCatTaxe,
                  nomCatTaxe: nomCatTaxe,
                  taux_personnel: taux_personnel,
                  taux_morale: taux_morale,
                  periode: periode,
                  jourEcheance: jourEcheance,
                  date_debit: date_debit,
                  date_fin: date_fin,
                  forme_calcul: forme_calcul,
                  type_taux: type_taux,
                  id: id,
                ))).then((value) {
      if (value) {
        //This will be called
        _refresh();
      }
    });
  }

  deleteData(int noteId) {
    db.deleteCatTaxe(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refresh();
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = handler.fetchCatTaxe();

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
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddNomaclature()))
              .then((value) {
            if (value) {
              //This will be called
              _refresh();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          Column(
            children: [
              const LayoutHeader(
                  title: "Catégorie de Taxe",
                  subTitle:
                      "Liste des catégories de taxes utlisable au système hors connexion"),

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
                            color:
                                Theme.of(context).primaryColor.withOpacity(.2),
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

              // fin listes
            ],
          ),

          //list data

          //table
          Expanded(
            child: FutureBuilder<List<CategoryTaxeModel>>(
              future: notes,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CategoryTaxeModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data"));
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  final items = snapshot.data ?? <CategoryTaxeModel>[];

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
      ),
    );
  }

  // Helper method to build a note card
  Widget buildDataCard(BuildContext context, CategoryTaxeModel note) {
    return Card(
        color: ConfigurationApp.whiteColor,
        child: GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: CircleAvatar(
                backgroundColor: ConfigurationApp.successColor,
                child: Image.asset('assets/images/avatar.jpg',
                    fit: BoxFit.cover, height: 30, width: 30)),
            title: Text(note.nomCatTaxe ?? "",
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 12,
                    ),
                    Text(
                      note.periode ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      size: 12,
                    ),
                    Text(
                      'du ${note.date_debit}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      size: 12,
                    ),
                    Text(
                      'au ${note.date_fin} ',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.countertops_outlined, size: 12),
                    Text(
                      '${note.jourEcheance!} jours',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Wrap(
              children: [
                IconButton(
                    onPressed: () {
                      updateData(
                          note.nomCatTaxe,
                          note.taux_personnel,
                          note.taux_morale,
                          note.periode,
                          note.jourEcheance,
                          note.date_debit,
                          note.date_fin,
                          note.forme_calcul,
                          note.type_taux,
                          note.id,
                          note.idCatTaxe);
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: ConfigurationApp.successColor,
                    )),
                IconButton(
                    onPressed: () {
                      deleteData(note.idCatTaxe!);
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
