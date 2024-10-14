import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/DetailTaxation/addDetailTaxation.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/detailTaxation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

class DetailTaxationScrem extends StatefulWidget {
  const DetailTaxationScrem(
      {super.key, this.idTaxation, this.codeNote, this.idUser});
  final int? idTaxation;
  final String? codeNote;
  final int? idUser;

  @override
  State<DetailTaxationScrem> createState() => _DetailTaxationScremState();
}

class _DetailTaxationScremState extends State<DetailTaxationScrem> {
  late List UserList;
  late DatabaseHelper handler;
  late Future<List<DetailTaxationModel>> notes;
  final db = DatabaseHelper();

  late Timer timer;

  bool loading = true;

  final keyword = TextEditingController();

  Future fetchDataList() async {
    // handler.DropTableIfExistsThenReCreateTaxation();
    List datas = await handler.fetchDataListTaxation();
    setState(() {
      UserList = datas;
    });

    // print(UserList);
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
  Future<List<DetailTaxationModel>> getAllNotes() {
    return handler.fetchDetailTaxation(widget.idTaxation);
  }

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<DetailTaxationModel>> searchNote() {
    return handler.searchDetailTaxations(keyword.text, widget.idTaxation);
  }

  //Refresh method
  Future<void> _refresh() async {
    if (widget.idTaxation != null) {
      setState(() {
        notes = getAllNotes();
        fetchDataList();
      });

      // print(notes);
    }
  }

  updateData(
      String? codeNote,
      int? qte,
      int? pu,
      int? montantReel,
      int? idCatTaxe,
      String? periode,
      String? datePeriodeDebit,
      String? datePeriodeFin,
      String? passager,
      String? commentaire,
      int? idTaxation,
      int? id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddDetailTaxation(
                  noteId: id,
                  idTaxation: idTaxation,
                  qte: qte.toString(),
                  pu: pu.toString(),
                  idCatTaxe: idCatTaxe,
                  montantReel: montantReel.toString(),
                  datePeriodeDebit: datePeriodeDebit,
                  datePeriodeFin: datePeriodeFin,
                  commentaire: commentaire,
                  periode: periode,
                  passager: passager,
                  codeNote: codeNote,
                ))).then((value) {
      if (value) {
        //This will be called
        _refresh();
      }
    });
  }

  deleteData(int noteId) {
    db.deleteDetailTaxation(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refresh();
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  @override
  void initState() {
    handler = DatabaseHelper();

    super.initState();

    setState(() {
      loading = false;
      notes = handler.fetchDetailTaxation(widget.idTaxation);
    });
    // print(notes);

    // autre
    fetchDataList();

    // isInteret();
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
      appBar: AppBar(
        title: const Text("Détail taxation "),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddDetailTaxation(
                              idTaxation: widget.idTaxation,
                              codeNote: widget.codeNote,
                            ))).then((value) {
                  if (value) {
                    //This will be called
                    _refresh();
                  }
                });
              },
              tooltip: "Ajouter une taxation ",
              icon: const Icon(Icons.add)),
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
                title: 'Liste des taxations',
                subTitle:
                    "Référence de la note ${widget.idTaxation} - ${widget.codeNote}. Cliquer sur un bouton afin d'effectuer une opération!!!"),
            //autre widget ici
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
                      notes = searchNote();
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

            //fin recherche

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: FutureBuilder<List<DetailTaxationModel>>(
                        future: notes,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<DetailTaxationModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasData &&
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text("No data"));
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          } else {
                            final items =
                                snapshot.data ?? <DetailTaxationModel>[];

                            return ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Transform.translate(
                                    offset: const Offset(0, -1),
                                    child: cartBuilder(context, items[index]),
                                  );
                                });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            //list de table
          ],
        ),
      ),
    );
  }

  //widget
  Widget cartBuilder(BuildContext context, DetailTaxationModel note) {
    return Card(
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        isThreeLine: true,
        title: Text(
          note.nomCatTaxe ?? "",
          maxLines: 4,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      size: 16,
                    ),
                    Text(
                      'Période: ${note.periode ?? ""} ',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 16,
                    ),
                    Text(
                      'Montant: ${note.montantReel ?? "0"} Usd',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
            Text(
              'Passager: ${note.passager ?? ""} ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Quantité: ${note.qte} ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Prix: ${note.pu} ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Mise à jour : ${DateFormat("yMd").format(DateTime.parse(note.createdAt.toString()))}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Wrap(
          children: [
            IconButton(
                onPressed: () {
                  updateData(
                      note.codeNote,
                      note.qte,
                      note.pu,
                      note.montantReel,
                      note.idCatTaxe,
                      note.periode,
                      note.datePeriodeDebit,
                      note.datePeriodeFin,
                      note.passager,
                      note.commentaire,
                      note.idTaxation,
                      note.id);
                },
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  deleteData(int.parse(note.id.toString()));
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ))
          ],
        ),
      ),
    );
  }
  // fin widget
}
