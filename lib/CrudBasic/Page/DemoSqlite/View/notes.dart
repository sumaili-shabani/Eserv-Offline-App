import 'dart:async';
import 'package:demoapp/CrudBasic/Api/my_api.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/create_note.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/note_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
//impression importation
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/invoice.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late DatabaseHelper handler;
  late Future<List<NoteModel>> notes;
  final db = DatabaseHelper();

  final title = TextEditingController();
  final content = TextEditingController();
  final codeNote = TextEditingController();
  final keyword = TextEditingController();

  late Timer timer;

  final PdfGenerator pdfGenerator = PdfGenerator();

  /*
  *
  *=========================
  * Synchronisation
  *=========================
  */
  late List list;
  bool loading = true;
  Future userList() async {
    list = await handler.fetchDataList();
    setState(() {
      loading = false;
    });
    // print(list);
  }

  Future syncToMysql() async {
    await handler.fetchAllInfo().then((infoDataList) async {
      EasyLoading.show(
          status: "Ne fermez pas l'application. nous sommes synchronisés...");
      userList();
      // envoie des données au serveur en ligne
      await handler.saveToMysql(list);

      EasyLoading.showSuccess("Sauvegarde réussie sur la BD online");
      setState(() {
        _refresh();
      });
    });
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
  *=========================
  * Fin Synchronisation
  *=========================
  */

  @override
  void initState() {
    handler = DatabaseHelper();
    notes = handler.getNotes();

    handler.initDB().whenComplete(() {
      notes = getAllNotes();
    });
    super.initState();

    // autre
    userList();
    isInteret();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        timer.cancel();
      }
    });
    // fin
  }

  Future<List<NoteModel>> getAllNotes() {
    return handler.getNotes();
  }

  //Search method here
  //First we have to create a method in Database helper class
  Future<List<NoteModel>> searchNote() {
    return handler.searchNotes(keyword.text);
  }

  //Refresh method
  Future<void> _refresh() async {
    setState(() {
      notes = getAllNotes();
      userList();
    });
  }

  deleteData(int noteId) {
    db.deleteNote(noteId).whenComplete(() {
      //After success delete , refresh notes
      _refresh();
      CallApi.showMsg("Suppression avec succès!!!");
    });
  }

  updateData(int noteId, String title, String description, String code) {
    Navigator.push(
        context as BuildContext,
        MaterialPageRoute(
            builder: (context) => CreateNote(
                  title: title,
                  content: description,
                  code: code,
                  noteId: noteId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Notes"),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh_sharp),
                tooltip: "Synchroniser les données",
                onPressed: () async {
                  await handler.isInternet().then((connection) {
                    if (connection) {
                      syncToMysql();
                      print("Internet connection abailale");
                    } else {
                      CallApi.showErrorMsg("Pas de connexion internet");
                    }
                  });
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //We need call refresh method after a new note is created
            //Now it works properly
            //We will do delete now
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateNote()))
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
          children: [
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

            // debit
            // voir le qrcode
            // const QrcodeGenerateImage(text: "Roger-1234567890", size: 150.0),

            // fin

            Expanded(
              child: FutureBuilder<List<NoteModel>>(
                future: notes,
                builder: (BuildContext context,
                    AsyncSnapshot<List<NoteModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("No data"));
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    final items = snapshot.data ?? <NoteModel>[];

                    return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return buildNoteCard(context, items[index]);
                        });
                  }
                },
              ),
            ),
          ],
        ));
  }

  // Helper method to build a note card
  Widget buildNoteCard(BuildContext context, NoteModel note) {
    return Card(
      child: GestureDetector(
        onTap: () => {},
        child: ListTile(
          leading: note.noteEtat == 0
              ? const Icon(
                  Icons.note,
                  color: Colors.orange,
                )
              : const Icon(
                  Icons.check_box_outlined,
                  color: Colors.green,
                ),
          title: Text(
            note.noteTitle ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              '${note.noteCode} créée le ${DateFormat("yMd").format(DateTime.parse(note.createdAt))}'),
          trailing: Wrap(
            children: [
              note.noteEtat == 0
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateNote(
                                      title: note.noteTitle,
                                      content: note.noteContent,
                                      code: note.noteCode,
                                      noteId: note.noteId!,
                                    ))).then((value) {
                          if (value) {
                            //This will be called
                            _refresh();
                          }
                        });
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    )
                  : IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.remove_red_eye_outlined,
                      ),
                    ),
              //impression
              IconButton(
                onPressed: () async {
                  // impression

                  generatePdfInvoce();
                },
                icon: const Icon(
                  Icons.print,
                  color: Color.fromARGB(255, 8, 0, 255),
                ),
              ),
              note.noteEtat == 0
                  ? IconButton(
                      onPressed: () {
                        // ignore: void_checks
                        deleteData(note.noteId!);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromARGB(255, 255, 81, 0),
                      ),
                    )
                  : IconButton(
                      onPressed: () {},
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
}
