import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/invoice.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator_recu.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/ButtonComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/DetailTaxation/addDetailTaxation.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/DetailTaxation/detailTaxation.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxation/AddTaxation.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/Taxation_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/detailTaxation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
//impression importation
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/invoice.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaxationScreem extends StatefulWidget {
  const TaxationScreem({super.key});

  @override
  State<TaxationScreem> createState() => _TaxationScreemState();
}

class _TaxationScreemState extends State<TaxationScreem> {
  late List UserList;
  late DatabaseHelper handler;
  late Future<List<TaxationModel>> notes;
  final db = DatabaseHelper();

  late Timer timer;

  final nomController = TextEditingController();
  final keyword = TextEditingController();

  Future fetchDataList() async {
    // handler.DropTableIfExistsThenReCreateTaxation();
    List datas = await handler.fetchDataListTaxation();
    setState(() {
      UserList = datas;
    });

    // print(UserList);
  }

  Future insertUserOnLineToOfflineCompte() async {
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
  Future<List<TaxationModel>> getAllNotes() {
    return handler.fetchTaxation();
  }

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<TaxationModel>> searchNote() {
    return handler.searchTaxations(keyword.text);
  }

  //Refresh method
  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
      fetchDataList();
    });
  }

  updateData(String? devise, String? codeNote, String? anneeFiscale,
      String? comment, String? dateTaxation, int? idCb, int? idTaxation) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddTaxation(
                  noteId: idTaxation,
                  devise: devise,
                  anneeFiscale: anneeFiscale,
                  comment: comment,
                  dateTaxation: dateTaxation,
                  idCb: idCb,
                  codeNote: codeNote,
                ))).then((value) {
      if (value != false) {
        //This will be called
        _refresh();
      }
    });
  }

  deleteData(int noteId) {
    db.deleteTaxation(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refresh();
      CallApi.showMsg("Suppression avec succès!!!");
    });
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
      _refresh();
      CallApi.showMsg("La note a été valider avec succès!!!");
    });
  }

  validerStatutNote(BuildContext context, int noteId) {
    showAlertDialog(context, noteId);
  }

  @override
  void initState() {
    handler = DatabaseHelper();

    handler.initDB();
    super.initState();

    // autre
    fetchDataList();
    setState(() {
      notes = getAllNotes();
    });

    // isInteret();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        timer.cancel();
      }
    });
    // fin

    getInfoConnected();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddTaxation()))
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
                  title: "Taxation",
                  subTitle: "Liste des taxations  au système hors connexion"),

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
                              hintText: 'Recherche ref note...',
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
            child: FutureBuilder<List<TaxationModel>>(
              future: notes,
              builder: (BuildContext context,
                  AsyncSnapshot<List<TaxationModel>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data"));
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  final items = snapshot.data ?? <TaxationModel>[];

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
  Widget buildDataCard(BuildContext context, TaxationModel note) {
    return Card(
        color: ConfigurationApp.whiteColor,
        child: GestureDetector(
          child: ListTile(
            onTap: () {
              _showForm(note);
            },
            leading: CircleAvatar(
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
                        'le ${DateFormat("yMd").format(DateTime.parse(note.dateTaxation.toString()))}'),
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
                        'du ${DateFormat("yMd").format(DateTime.parse(note.dateTaxation.toString()))}'),
                  ],
                ),
              ],
            ),
            trailing: Wrap(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Devise: ${note.devise}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'A-Fisc: ${note.anneeFiscale}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      _showForm(note);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                    )),
                note.etatNoteSync == 0
                    ? note.statut == 0
                        ? //voir le popup
                        IconButton(
                            onPressed: () {
                              deleteData(note.idTaxation!);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
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

  // showw form edit
  void _showForm(TaxationModel note) async {
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
                    Column(
                      children: <Widget>[
                        Text(' ${note.codeNote}',
                            style: const TextStyle(fontSize: 20)),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 100,
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                onTap: () {},
                                leading: CircleAvatar(
                                    backgroundColor:
                                        ConfigurationApp.successColor,
                                    child: CircleAvatar(
                                        backgroundColor:
                                            ConfigurationApp.successColor,
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
                                title: note.idtypeCb == 1
                                    ? Text(
                                        note.nomCompletCb ??
                                            '/${note.idtypeCb == 1 ? note.typeCb : ""}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        note.nomEts ??
                                            ""
                                                '/${note.idtypeCb == 1 ? note.typeCb : ""}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
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
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
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
                                            'Note Créée le ${DateFormat("yMd").format(DateTime.parse(note.dateTaxation.toString()))}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.event,
                                          size: 12,
                                        ),
                                        Text(
                                            'à la date du ${DateFormat("yMd").format(DateTime.parse(note.dateTaxation.toString()))}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 50,
                                color: ConfigurationApp.whiteColor,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: note.statut == 0
                                      ? ButtonComponent(
                                          label: "Taxation",
                                          press: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddDetailTaxation(
                                                          idTaxation:
                                                              note.idTaxation,
                                                          codeNote:
                                                              note.codeNote,
                                                          idUser: note.idUser,
                                                        ))).then((value) {
                                              if (value) {
                                                //This will be called
                                                _refresh();
                                              }
                                            });
                                          },
                                          icon: Icons.note_add,
                                        )
                                      : ButtonComponent(
                                          label: "Pdf Reçu",
                                          press: () {
                                            generatePdfRecuTaxation(note);
                                          },
                                          icon: Icons.print,
                                        ),
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 50,
                              color: Colors.white,
                              child: note.statut == 0
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetailTaxationScrem(
                                                            idTaxation:
                                                                note.idTaxation,
                                                            codeNote:
                                                                note.codeNote,
                                                            idUser: note.idUser,
                                                          ))).then((value) {
                                                if (value != false) {
                                                  //This will be called
                                                  _refresh();
                                                }
                                              });
                                            },
                                            tooltip:
                                                "Voir la liste de sa taxation",
                                            icon: const Icon(
                                              Icons.tab,
                                              color:
                                                  ConfigurationApp.successColor,
                                            )),
                                        IconButton(
                                            onPressed: () {
                                              validerStatutNote(
                                                  context, note.idTaxation!);
                                            },
                                            tooltip: "Valider la note",
                                            icon: const Icon(
                                              Icons.check_box,
                                              color:
                                                  ConfigurationApp.successColor,
                                            )),
                                        IconButton(
                                            onPressed: () {
                                              updateData(
                                                note.devise,
                                                note.codeNote,
                                                note.anneeFiscale,
                                                note.comment,
                                                note.dateTaxation,
                                                note.idCb,
                                                note.idTaxation,
                                              );
                                            },
                                            tooltip:
                                                "Modifier la note avant la validation",
                                            icon: const Icon(
                                              Icons.edit,
                                              color:
                                                  ConfigurationApp.successColor,
                                            )),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ButtonComponent(
                                          label: "Imprimer",
                                          press: () {
                                            generatePdfRecuTaxation(note);
                                          },
                                          icon: Icons.print,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  // fin show form id

  /*
  *
  *=================================
  * Description de l'impression
  *=================================
  *
  */

  final PdfGeneratorRecu pdfGeneratorRecu = PdfGeneratorRecu();
  String connected = "";

  getInfoConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('fullNameConnected')!;
    });
  }

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
        name: 'Fournisseur',
        address: 'Adresse fournisseur',
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

    // print("Path - ${pdfFile.path}");
    Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
    );
  }

  //fin impression

  /*
  *
  *=================================
  * Description de l'impression
  *=================================
  *
  */
}
