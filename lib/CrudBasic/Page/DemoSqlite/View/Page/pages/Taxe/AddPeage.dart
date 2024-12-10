import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/DateTextFildComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/TextFildComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/PeageModel.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/immatriculationModel.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// impression
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/pdf_generator_recu_peage_route.dart';

//impression importation
import 'package:demoapp/CrudBasic/Page/DemoSqlite/PdfGenereteModule/invoice.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPeage extends StatefulWidget {
  AddPeage({
    this.idPeage,
    this.nomCb,
    this.idCatTaxe,
    this.idSousLibelle,
  });
  final int? idPeage;
  final String? nomCb;
  final int? idCatTaxe;
  final int? idSousLibelle;

  @override
  State<AddPeage> createState() => _AddPeageState();
}

class _AddPeageState extends State<AddPeage> {
  final PdfGenerator pdfGenerator = PdfGenerator();
  final PdfGeneratorRecuPeageRoute pdfGeneratorRecuPeage =
      PdfGeneratorRecuPeageRoute();

  final idCatTaxe = TextEditingController();
  final idUser = TextEditingController();
  final qte = TextEditingController();
  final pu = TextEditingController();
  final montantUsd = TextEditingController();
  final nomAgent = TextEditingController();
  final nomCb = TextEditingController();
  final telCb = TextEditingController();
  final marqueVehicule = TextEditingController();
  final modelVehicule = TextEditingController();
  final chassieVehicule = TextEditingController();
  final numPlaque = TextEditingController();
  final devise = TextEditingController();
  final datePaiement = TextEditingController();
  final codeNote = TextEditingController();
  final comment = TextEditingController();
  final nomCatTaxe = TextEditingController();
  final idSousLibelle = TextEditingController();

  final formKey = GlobalKey<FormState>();

  // ignore: non_constant_identifier_names, prefer_interpolation_to_compose_strings
  String CodeRandom =
      'ref-${Random().nextInt(1000000)}-${Random().nextInt(9000000)}';
  String toDay = '${DateFormat("yyyy-MM-dd hh:mm")}';

  final db = DatabaseHelper();
  late DatabaseHelper handler;

  bool editMode = false;

  String? idCatTaxeSelected;
  String? idSousLibelleSelected;
  int idConnected = 0;
  int myidSousLibelleSelected = 0;
  String connected = "";

  late List listCatTaxe = [];

  late List listImmatriculation = [];
  Future fetchDataList() async {
    handler = DatabaseHelper();
    List datas = await handler.fetchDataListImmatriculation();
    setState(() {
      listImmatriculation = datas;
    });
    // print(' Liste immatriculation:  $listImmatriculation');
  }

  Future getCatTaxeSelected(int id) async {
    handler = DatabaseHelper();
    List datas = await handler.getCatTaxeSelected(id);
    for (var i = 0; i < datas.length; i++) {
      setState(() {
        qte.text = '1';
        pu.text = datas[i]['taux_personnel'].toString();
        montantUsd.text = datas[i]['taux_personnel'].toString();
        nomCatTaxe.text = datas[i]['nomCatTaxe'].toString();
      });
    }

    // print(' Liste cb:  $listCb');
  }

  Future getCatTaxeByImatriculation(int idSousLibelle) async {
    handler = DatabaseHelper();
    List datas =
        await handler.getCatTaxeSelectedByImmatriculation(idSousLibelle);
    setState(() {
      listCatTaxe = datas;
    });

    print(' Liste Cat taxe:  $listCatTaxe');
  }

  @override
  void initState() {
    super.initState();

    handler = DatabaseHelper();

    if (widget.idPeage != null) {
      editMode = true;
      nomCb.text = widget.nomCb.toString();

      //initialisation
      if (idCatTaxe.text != 'null') {
        idCatTaxeSelected = widget.idCatTaxe.toString();
      }

      if (idSousLibelle.text != 'null') {
        idCatTaxeSelected = widget.idSousLibelle.toString();
      }

      devise.text = 'Usd';

      //fin initialisation
    } else {
      codeNote.text = CodeRandom.toString();
      devise.text = 'Usd';
    }

    fetchDataList();
  }

  inserOrUpdateData() async {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
      } else {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        idConnected = localStorage.getInt('idConnected')!;
        connected = localStorage.getString('fullNameConnected')!;

        if (nomCb.text != '' && qte.text != '' && idCatTaxeSelected != '') {
          Map<String, dynamic> svData = {
            'idCatTaxe': int.parse(idCatTaxe.text.toString()),
            'idUser': int.parse(idConnected.toString()),
            'codeNote': codeNote.text.toString(),
            'nomCb': nomCb.text.toString(),
            'telCb': telCb.text.toString(),
            'nomAgent': connected.toString(),
            'marqueVehicule': marqueVehicule.text.toString(),
            'modelVehicule': modelVehicule.text.toString(),
            'chassieVehicule': chassieVehicule.text.toString(),
            'numPlaque': numPlaque.text.toString(),
            'datePaiement': datePaiement.text.toString(),
            'nomCatTaxe': nomCatTaxe.text.toString(),
            'devise': devise.text.toString(),
            'qte': int.parse(qte.text.toString()),
            'pu': double.parse(pu.text.toString()),
            'montantUsd': double.parse(montantUsd.text.toString()),
          };
          db.insertPeageData(svData).whenComplete(() {
            //When this value is true
            Navigator.of(context).pop(true);
            CallApi.showMsg("Insertion avec succès!!!");
            generatePdfRecuTaxation(codeNote.text);
          });
        } else {
          CallApi.showErrorMsg("Veillez compléter tous les champs!!!");
        }
      }
    }
  }

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
            icon: editMode ? const Icon(Icons.check) : const Icon(Icons.print),
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
                title: 'Formulaire de Péage route',
                subTitle:
                    "Cliquer sur un bouton afin d'effectuer une opération!!!"),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextFildComponent(
                      labeltext: "Nom de Contribuable",
                      hint: "Entrez le nom de Contribuable",
                      icon: Icons.person,
                      controller: nomCb,
                      maxLines: 1,
                      validatorInput: true,
                    ),
                    //formulaire
                    const SizedBox(
                      height: 5,
                    ),
                    TextFildComponent(
                      labeltext: "N° de téléphone de Contribuable",
                      hint: "Entrez le N° de téléphone de Contribuable",
                      icon: Icons.call,
                      controller: telCb,
                      maxLines: 1,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                      labeltext: "Marque du véhucule",
                      hint: "Entrez la marque du véhucule",
                      icon: Icons.car_crash,
                      controller: marqueVehicule,
                      maxLines: 1,
                      validatorInput: false,
                    ),
                    TextFildComponent(
                      labeltext: "Model du véhucule",
                      hint: "Entrez la marque du véhucule",
                      icon: Icons.car_repair_outlined,
                      controller: modelVehicule,
                      maxLines: 1,
                      validatorInput: false,
                    ),
                    TextFildComponent(
                      labeltext: "Numéro chassie du véhucule",
                      hint: "Entrez le numéro chassie du véhucule",
                      icon: Icons.car_rental,
                      controller: chassieVehicule,
                      maxLines: 1,
                      validatorInput: false,
                    ),
                    TextFildComponent(
                      labeltext: "N° de plaque du véhucule",
                      hint: "Entrez le N° plaque du véhucule",
                      icon: Icons.car_crash,
                      controller: numPlaque,
                      maxLines: 1,
                      validatorInput: false,
                    ),

                    //combo box
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: DropdownButton<String>(
                        value: idCatTaxeSelected,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Selectionner l'immatriculation"),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: listImmatriculation.map((list) {
                          return DropdownMenuItem(
                            value: list['idSousLibelle'].toString(),
                            child: Text(list['nomSousLibelle']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            idCatTaxeSelected = value.toString();
                            getCatTaxeByImatriculation(
                                int.parse(value.toString()));
                          });
                        },
                      ),
                    ),
                    const Divider(color: Colors.black),
                    //combo box
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: DropdownButton<String>(
                        value: idSousLibelleSelected,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Catégorie de véhucule"),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: listCatTaxe.map((list) {
                          return DropdownMenuItem(
                            value: list['id'].toString(),
                            child: Text(list['nomCatTaxe']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          // print(value);
                          idSousLibelleSelected = value.toString();
                          idSousLibelle.text = idSousLibelleSelected.toString();
                          setState(() {
                            idCatTaxe.text = value.toString();
                            getCatTaxeSelected(int.parse(value.toString()));
                          });
                        },
                      ),
                    ),
                    const Divider(color: Colors.black),
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
                              labeltext: "Date de paiement ",
                              hint: "Entrez la date de Période fin",
                              icon: Icons.event,
                              controller: datePaiement,
                              validatorInput: true),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          color: Colors.white10,
                          child: TextFildComponent(
                            labeltext: "Devise",
                            hint: "Entrez la date de Période fin",
                            icon: Icons.account_balance_wallet,
                            controller: devise,
                            validatorInput: true,
                            enabledChamps: false,
                          ),
                        ),
                      ],
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
                              validatorInput: true,
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
                                  double prix =
                                      double.parse(pu.text.toString());
                                  double prixTotal =
                                      prix * double.parse(qte.text.toString());
                                  setState(() {
                                    montantUsd.text =
                                        prixTotal.toStringAsFixed(2);
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          color: Colors.white10,
                          child: TextFildComponent(
                            labeltext: "Taux de péage",
                            hint: "Entrez le Prix unitaire",
                            icon: Icons.payments,
                            controller: pu,
                            maxLines: 1,
                            enabledChamps: false,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          color: Colors.white10,
                          child: TextFildComponent(
                            labeltext: "Total à payer Usd",
                            hint: "Entrez le Prix unitaire",
                            icon: Icons.payments,
                            controller: montantUsd,
                            maxLines: 1,
                            enabledChamps: false,
                          ),
                        ),
                      ],
                    ),

                    // TextFildComponent(
                    //   labeltext: "Catégorie de taxe",
                    //   hint: "Entrez le Commentaire",
                    //   icon: Icons.note_alt_outlined,
                    //   controller: nomCatTaxe,
                    //   maxLines: 2,
                    //   validatorInput: true,
                    //   enabledChamps: false,
                    // ),

                    TextFildComponent(
                      labeltext: "Code Note",
                      hint: "Entrez le Commentaire",
                      icon: Icons.code,
                      controller: codeNote,
                      maxLines: 1,
                      validatorInput: true,
                      enabledChamps: false,
                    ),
                    // TextFildComponent(
                    //   labeltext: "idCatTaxe",
                    //   hint: "Entrez le Commentaire",
                    //   icon: Icons.code,
                    //   controller: idCatTaxe,
                    //   maxLines: 1,
                    //   validatorInput: true,
                    //   enabledChamps: false,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //impression
  void generatePdfRecuTaxation(String codeNote) async {
    List<PeageModel> detailTaxationList = [];
    List<PeageModel> liste = await handler.fetchDetailPeageByCodeNote(codeNote);

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

      //default

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
          number: codeNote.toString(),
        ),
        items: listeItem,
      );

      final pdfFile = await pdfGeneratorRecuPeage.generateReceiptPdfRecu(
          receiptNumber: codeNote.toString(),
          date: datePaiement.toString(),
          customerName: infoTaxe.nomCb.toString(),
          amount: 99.99,
          invoice: invoice,
          infoTaxation: infoTaxe,
          connected: infoTaxe.nomCb.toString(),
          passager: Passager);

      print("Path - ${pdfFile.path}");
      Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
      );
    }
    // print("cool roger ok: $Passager ");
  }

  //fin impression
}
