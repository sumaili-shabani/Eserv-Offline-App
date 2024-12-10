import 'dart:async';
import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxe/AddPeage.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/PeageModel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

// impression
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator_recu_peage_route.dart';

//impression importation
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/invoice.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeageRoute extends StatefulWidget {
  const PeageRoute({super.key});

  @override
  State<PeageRoute> createState() => _PeageRouteState();
}

class _PeageRouteState extends State<PeageRoute> {
  late List UserList;
  late DatabaseHelper handler;
  late Future<List<PeageModel>> notes;
  final db = DatabaseHelper();

  late Timer timer;
  final keyword = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final PdfGenerator pdfGenerator = PdfGenerator();
  final PdfGeneratorRecuPeageRoute pdfGeneratorRecuPeage =
      PdfGeneratorRecuPeageRoute();

  Future fetchDataList() async {
    // handler.DropTableIfExistsThenReCreateCattaxe();
    List datas = await handler.fetchDataListPeage();
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
  Future<List<PeageModel>> getAllNotes() {
    return handler.getPeages();
  }

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<PeageModel>> searchNote() {
    return handler.searchPeages(keyword.text);
  }

  //Refresh method
  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
      fetchDataList();
    });
  }

  deleteData(int noteId) {
    db.deletePeage(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refresh();
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  String connected = '';
  getInfoConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('fullNameConnected')!;
    });
  }

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = handler.getPeages();

    handler.initDB().whenComplete(() {
      notes = getAllNotes();
    });
    super.initState();

    // autre
    fetchDataList();
    getInfoConnected();
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
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: ConfigurationApp.successColor,
          foregroundColor: ConfigurationApp.whiteColor,
          onPressed: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddPeage()))
                .then((value) {
              if (value) {
                //This will be called
                _refresh();
              }
            });
            fetchDataList();
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            const LayoutHeader(
                title: 'Péage route',
                subTitle: "Liste de paiement au système hors connexion"),
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
              child: FutureBuilder<List<PeageModel>>(
                future: notes,
                builder: (BuildContext context,
                    AsyncSnapshot<List<PeageModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("No data"));
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    final items = snapshot.data ?? <PeageModel>[];

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
  Widget buildDataCard(BuildContext context, PeageModel note) {
    return Card(
        color: ConfigurationApp.whiteColor,
        child: GestureDetector(
          child: ListTile(
            onTap: () {},
            leading: CircleAvatar(
                backgroundColor: note.statutPeage == 1
                    ? ConfigurationApp.successColor
                    : ConfigurationApp.primaryColor,
                child: note.statutPeage == 1
                    ? const Icon(
                        Icons.check_box,
                        color: ConfigurationApp.whiteColor,
                      )
                    : const Icon(
                        Icons.description,
                        color: ConfigurationApp.whiteColor,
                      )),
            title: Text(note.nomCatTaxe ?? "",
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            subtitle: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 15,
                    ),
                    Text(
                      'Montant: ${note.qte} * ${double.parse(note.pu.toString())} = ${double.parse(note.montantUsd.toString())} Usd',
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
                      Icons.code,
                      size: 15,
                    ),
                    Text(
                      'Réf: ${note.codeNote}',
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
                      size: 15,
                    ),
                    Text(
                      'Date: ${DateFormat("yMd").format(DateTime.parse(note.createdAt.toString()))}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.person_pin_outlined,
                      size: 15,
                    ),
                    Text(
                      'Contribuable: ${note.nomCb}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Wrap(
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          generatePdfRecuTaxation(note);
                        },
                        icon: const Icon(
                          Icons.print,
                          color: ConfigurationApp.successColor,
                          size: 30,
                        )),
                    const SizedBox(
                      height: 1,
                    ),
                    Text(
                      '${note.montantUsd} Usd',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // IconButton(
                    //     onPressed: () {
                    //       deleteData(note.idPeage!);
                    //     },
                    //     icon: const Icon(
                    //       Icons.delete,
                    //       color: Colors.red,
                    //     )),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  //fin card

  /*
  *
  *===================
  * Impression du recu
  *===================
  */

  //impression
  void generatePdfRecuTaxation(PeageModel infoTaxation) async {
    List<PeageModel> detailTaxationList = [];
    List<PeageModel> liste =
        await handler.fetchDetailPeageByCodeNote(infoTaxation.codeNote);

    setState(() {
      detailTaxationList = liste;
    });
    late List<InvoiceItem> listeItem = [];
    String Passager = "";

    for (var i = 0; i < detailTaxationList.length; i++) {
      PeageModel infoTaxe = detailTaxationList[i];
      listeItem.add(InvoiceItem(
        description: infoTaxe.nomCatTaxe.toString(),
        date: DateTime.now(),
        quantity: int.parse(infoTaxe.qte.toString()),
        vat: double.parse(infoTaxe.montantUsd.toString()),
        unitPrice: double.parse(infoTaxe.pu.toString()),
      ));
      Passager = infoTaxe.telCb.toString();
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
    final pdfFile = await pdfGeneratorRecuPeage.generateReceiptPdfRecu(
        receiptNumber: infoTaxation.codeNote.toString(),
        date: infoTaxation.datePaiement.toString(),
        customerName: infoTaxation.nomCb.toString(),
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
}
