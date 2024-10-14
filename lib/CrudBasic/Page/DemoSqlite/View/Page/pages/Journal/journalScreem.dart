import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/Components/bar_chart_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/ButtonComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/CardDashBordComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class JournalScreem extends StatefulWidget {
  const JournalScreem({super.key});

  @override
  State<JournalScreem> createState() => _JournalScreemState();
}

class _JournalScreemState extends State<JournalScreem> {
  late DatabaseHelper handler;
  final db = DatabaseHelper();
  late Timer _timer;
  List dashList = [];
  Future getDashbord() async {
    int countCatTaxation = await handler.getQueryCount("category_taxes");
    int countCb = await handler.getQueryCount("contibuables");
    int countCbOnline =
        await handler.getQueryCountTableWhere("contibuables", "etatCb", 1);
    int countCbOffline =
        await handler.getQueryCountTableWhere("contibuables", "etatCb", 0);
    int countCbPphysique =
        await handler.getQueryCountTableWhere("contibuables", "idtypeCb", 1);
    int countCbPmorale =
        await handler.getQueryCountTableWhere("contibuables", "idtypeCb", 2);
    int sumMontantTaxation =
        await handler.getQuerySum("detail_taxations", "montant_reel");
    int sumMontantTaxationOffLine = await handler.getQuerySumTaxation(0);
    int sumMontantTaxationOnline = await handler.getQuerySumTaxation(1);
    setState(() {
      dashList = [
        {
          //category_taxation
          'countCatTaxation': countCatTaxation,
          //contribuables
          'countCb': countCb,
          'countCbOnline': countCbOnline,
          'countCbOffline': countCbOffline,

          'countCbPphysique': countCbPphysique,
          'countCbPmorale': countCbPmorale,
          //sommation
          'sumMontantTaxation': sumMontantTaxation,
          'sumMontantTaxationOffLine': sumMontantTaxationOffLine,
          'sumMontantTaxationOnline': sumMontantTaxationOnline,
        }
      ];
    });

    // print(dashList);
  }

  late List<BarChartModel> dataStat = [];
  late List<BarChartModel> dataStatCatCb = [];
  Future getListDataChart() async {
    List<BarChartModel> listStat =
        await handler.getStatistiqueTaxation("dateTaxation");
    List<BarChartModel> listStatCatCb =
        await handler.getStatistiqueTaxation("idtypeCb");
    setState(() {
      dataStat = listStat;
      dataStatCatCb = listStatCatCb;
    });
    // print(dataStat);
  }

  /*
  *
  *=========================
  * Synchronisation
  *=========================
  */

  late List listData = [];
  bool loading = false;
  Future userList() async {
    setState(() {
      loading = true;
    });

    List cblistData = await handler.fetchDataListCb().whenComplete(() {
      setState(() {
        loading = false;
      });
    });
    setState(() {
      listData = cblistData;
    });
    // print(listData);
  }

  Future updateEtatCb() async {
    await handler.updateInitStoreEtatCb().whenComplete(() {
      fetchDataList();
      getDashbord();
      getListDataChart();
      CallApi.showMsg("Réunitialisation d'état avec succès!!!");
    });
  }

  Future updateEtatTaxation() async {
    await handler.updateInitStoreEtatTaxation().whenComplete(() {
      fetchDataList();
      getDashbord();
      getListDataChart();
      CallApi.showMsg("Réunitialisation d'état Taxation avec succès!!!");
    });
  }

  Future deleteDataTable() async {
    String table = "detail_taxations";
    await handler.deleteQueryDatatable(table).whenComplete(() {
      CallApi.showMsg("Supression de la table $table avec succès!!!");
    });
  }

  Future syncToMysqlCb() async {
    setState(() {
      loading = true;
    });
    await handler.fetchAllInfoCb().then((infoDataList) async {
      EasyLoading.show(
          status: "Ne fermez pas l'application. nous sommes synchronisés...");
      userList();
      // envoie des données au serveur en ligne
      await handler.saveToMysqlCb(listData);
      setState(() {
        userList();
        loading = false;
      });

      EasyLoading.showSuccess("Sauvegarde réussie sur la BD online");
    });
  }

  /*
  *
  *===============================
  * Synchronisation
  *===============================
  *
  */

  late List taxationList;
  int idConnected = 0;
  Future fetchDataList() async {
    List datas = await handler.fetchDataListTaxation();
    setState(() {
      taxationList = datas;
    });

    // print(taxationList);
  }

  Future syncToMysql() async {
    fetchDataList();
    setState(() {
      loading = true;
    });
    await handler.fetchDataListTaxation();
    EasyLoading.show(
        status: "Ne fermez pas l'application. nous sommes synchronisés...");

    await syncToMysqlCb().whenComplete(() {
      handler.saveToMysqlTaxation(taxationList).whenComplete(() {
        // Navigator.of(context).pop(true);

        getDashbord();
        setState(() {
          loading = false;
        });
      });
    });

    // envoie des données au serveur en ligne

    //When this value is true

    EasyLoading.showSuccess("Sauvegarde réussie sur la BD online");
    setState(() {
      fetchDataList();
      getDashbord();
      getListDataChart();
    });
  }

  // synchronisation

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

  @override
  void initState() {
    handler = DatabaseHelper();
    handler.initDB();
    super.initState();

    //appel de cb
    userList();
    //appel de taxation
    fetchDataList();
    //appel statistique
    getDashbord();
    getListDataChart();
    isInteret();

    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BarChartModel, String>> series = [
      charts.Series(
        id: "financial",
        data: dataStat,
        domainFn: (BarChartModel series, _) => series.year,
        measureFn: (BarChartModel series, _) => series.financial,
        colorFn: (BarChartModel series, _) =>
            series.color ?? charts.ColorUtil.fromDartColor(Colors.blue),
      ),
    ];
    List<charts.Series<BarChartModel, String>> series2 = [
      charts.Series(
        id: "financial",
        data: dataStat,
        domainFn: (BarChartModel series, _) => series.typeCb ?? series.year,
        measureFn: (BarChartModel series, _) => series.financial,
        colorFn: (BarChartModel series, _) =>
            series.color ??
            charts.ColorUtil.fromDartColor(ConfigurationApp.successColor),
      ),
    ];
    return Scaffold(
        body: loading == true
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const LayoutHeader(
                      title: 'Synchronisation',
                      subTitle:
                          "Effectuer une opération afin de synchroniser les données!!!"),
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
                                onPressed: () async {
                                  // await updateEtatCb();
                                  // await updateEtatTaxation();
                                  // await deleteDataTable();
                                  //appel de cb
                                  await userList();
                                  //appel de taxation
                                  await fetchDataList();
                                  //appel statistique
                                  await getDashbord();
                                  await getListDataChart();
                                },
                                child: const Text('En ligne'),
                              ),
                              const Icon(Icons.arrow_forward_ios,
                                  size: 13,
                                  color: ConfigurationApp.successColor),
                            ],
                          )
                        ]),
                  ),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width * 0.46,
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: ConfigurationApp.dangerColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Center(
                                child: CardDashboradComponent(
                              titre: "Cb Offline",
                              number: dashList.isNotEmpty
                                  ? dashList[0]["countCbOffline"].toString()
                                  : '0',
                              signeIcon: "",
                              icon: Icons.person_pin_outlined,
                              color: ConfigurationApp.dangerColor,
                              textcolor: ConfigurationApp.whiteColor,
                            )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width * 0.46,
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: ConfigurationApp.successColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Center(
                                child: CardDashboradComponent(
                              titre: "Taxation Offline",
                              number: dashList.isNotEmpty
                                  ? dashList[0]["sumMontantTaxationOffLine"]
                                      .toString()
                                  : '0',
                              signeIcon: "\$",
                              icon: Icons.payments_rounded,
                              color: ConfigurationApp.successColor,
                              textcolor: ConfigurationApp.whiteColor,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Statistique"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Analyse",
                                style: TextStyle(
                                    color: ConfigurationApp.successColor),
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  size: 13,
                                  color: ConfigurationApp.successColor),
                            ],
                          )
                        ]),
                  ),
                  Expanded(
                    flex: 4,
                    child: ListView(
                      children: [
                        //statistique
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            height: 400,
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: charts.BarChart(
                              series,
                              animate: true,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Statistique par catégorie"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Contribuable",
                                      style: TextStyle(
                                          color: ConfigurationApp.successColor),
                                    ),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 13,
                                        color: ConfigurationApp.successColor),
                                  ],
                                )
                              ]),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            height: 400,
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: charts.BarChart(
                              series2,
                              animate: true,
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            color: Colors.white,
                            height: 100,
                            child: Column(children: [
                              ButtonComponent(
                                label: "Synchroniser les données",
                                press: () async {
                                  await handler.isInternet().then((connection) {
                                    if (connection) {
                                      syncToMysql();
                                      print("Internet connection abailale");
                                    } else {
                                      CallApi.showErrorMsg(
                                          "Pas de connexion internet");
                                    }
                                  });
                                },
                                icon: Icons.refresh,
                              ),
                            ]),
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.all(8),
                        //   child: Container(
                        //     color: Colors.green[300],
                        //     height: 200,
                        //     child: const Center(
                        //         child: Text('Widget 1',
                        //             style: TextStyle(color: Colors.white))),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ));
  }
}
