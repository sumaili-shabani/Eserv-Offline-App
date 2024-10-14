import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Personnel/AddPersonnel.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PersonnelScreem extends StatefulWidget {
  const PersonnelScreem({super.key});

  @override
  State<PersonnelScreem> createState() => _PersonnelScreemState();
}

class _PersonnelScreemState extends State<PersonnelScreem> {
  late List UserList;
  late DatabaseHelper handler;
  late Future<List<Users>> notes;
  final db = DatabaseHelper();

  late Timer timer;

  final nomController = TextEditingController();
  final keyword = TextEditingController();

  Future fetchDataList() async {
    // handel.DropTableIfExistsThenReCreate();
    List datas = await handler.fetchDataListUser();
    setState(() {
      UserList = datas;
    });

    print(UserList);
  }

  Future insertUserOnLineToOfflineCompte() async {
    List datas = await handler.fetchDataListUser();
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
  Future<List<Users>> getAllNotes() {
    return handler.fetchUsers();
  }

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<Users>> searchNote() {
    return handler.searchUsers(keyword.text);
  }

  //Refresh method
  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
      fetchDataList();
    });
  }

  updateData(int noteId, String? id, String fullName, String email,
      String usrName, String usrPassword) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPersonnel(
                  noteId: noteId,
                  idUser: id,
                  fullName: fullName,
                  email: email,
                  usrName: usrName,
                  usrPassword: usrPassword,
                ))).then((value) {
      if (value) {
        //This will be called
        _refresh();
      }
    });
  }

  deleteData(int noteId) {
    db.deleteUser(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refresh();
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = handler.fetchUsers();

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
                  MaterialPageRoute(builder: (context) => AddPersonnel()))
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
                  title: "Comptes utilisateurs",
                  subTitle:
                      "Liste des utilisateurs ayant droit au système hors connexion"),

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
                              hintText: 'Search products',
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
            child: FutureBuilder<List<Users>>(
              future: notes,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Users>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data"));
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  final items = snapshot.data ?? <Users>[];

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

  //card

  // Helper method to build a note card
  Widget buildDataCard(BuildContext context, Users user) {
    return Card(
        color: ConfigurationApp.whiteColor,
        child: GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: Image.asset('assets/images/avatar.jpg',
                fit: BoxFit.cover, height: 50, width: 50),
            title: Text(user.fullName ?? "",
                style: Theme.of(context).textTheme.titleLarge),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.badge,
                      size: 12,
                    ),
                    Text(
                      user.usrName,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.email, size: 12),
                    Text(
                      user.email ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 3,
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
                          user.usrId!,
                          user.id.toString(),
                          user.fullName!,
                          user.email!,
                          user.usrName,
                          user.password);
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: ConfigurationApp.successColor,
                    )),
                IconButton(
                    onPressed: () {
                      deleteData(user.usrId!);
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
