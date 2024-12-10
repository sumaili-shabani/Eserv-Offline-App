import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/Components/bar_chart_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/ButtonComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/CardDashBordComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:intl/intl.dart';

class JournalPeageRoute extends StatefulWidget {
  const JournalPeageRoute({super.key});

  @override
  State<JournalPeageRoute> createState() => _JournalPeageRouteState();
}

class _JournalPeageRouteState extends State<JournalPeageRoute> {
  late DatabaseHelper handler;
  final db = DatabaseHelper();
  late Timer _timer;
  List dashList = [];
  Future getDashbord() async {
    int countCatTaxation = await handler.getQueryCount("category_taxes");

    //peage route
    int countPeageRouteOffline =
        await handler.getQueryCountTableWhere("peage", "statutPeage", 0);
    int sumMontantPeageRoute = await handler.getQuerySommePeageRoute();
    int sumMontantPeageRouteOffLine = await handler.getQuerySumPeageRoute(0);
    int sumMontantPeageRouteOnline = await handler.getQuerySumPeageRoute(1);
    setState(() {
      dashList = [
        {
          //peage route
          //category_taxation
          'countCatTaxation': countCatTaxation,
          //sommation
          'countPeageRouteOffline': countPeageRouteOffline,
          'sumMontantPeageRoute': sumMontantPeageRoute,
          'sumMontantPeageRouteOffLine': sumMontantPeageRouteOffLine,
          'sumMontantPeageRouteOnline': sumMontantPeageRouteOnline,
        }
      ];
    });

    // print(dashList);
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

  late List<BarChartModel> dataStat = [];
  Future getListDataChart() async {
    List<BarChartModel> listStat =
        await handler.getStatistiquePeageRoute("datePaiement");

    setState(() {
      dataStat = listStat;
    });
    // print(dataStat);
  }

  /*
  *
  *==============================
  * Fetch list statistique
  *==============================
  *
  */
  List venteList = [];
  Future getMesVentes() async {
    List infoStat = await handler.getListStatistiquePeageRoute("datePaiement");
    setState(() {
      venteList = infoStat;
    });
    // print(venteList);
  }

  late List listData = [];
  bool loading = false;
  Future userList() async {
    setState(() {
      loading = true;
    });

    List cblistData =
        await handler.fetchDataListPeageOffLine().whenComplete(() {
      setState(() {
        loading = false;
      });
    });
    setState(() {
      listData = cblistData;
    });
    // print(listData);
  }

  //synchronisation
  Future syncToMysqlPeageRoute() async {
    setState(() {
      loading = true;
    });
    await handler.fetchDataListPeageOffLine().whenComplete(() async {
      EasyLoading.show(
          status: "Ne fermez pas l'application. nous sommes synchronisés...");
      userList();
      // envoie des données au serveur en ligne
      await handler.saveToMysqlPeageRoute(listData).whenComplete(() {
        setState(() {
          userList();
          loading = false;
        });
      });

      EasyLoading.showSuccess("Sauvegarde réussie sur la BD online");
    });
  }

  @override
  void initState() {
    handler = DatabaseHelper();
    handler.initDB();
    super.initState();

    //appel statistique
    getDashbord();
    getListDataChart();
    getMesVentes();
    userList();
    // isInteret();

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
                  // pour le journal de ventes
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: venteList.length,
                      itemBuilder: (BuildContext context, index) {
                        var item = venteList[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 150,
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
                              titre: DateFormat("d/M/y")
                                  .format(DateTime.parse(item['year'])),
                              number: "${item['financial']}\$",
                              signeIcon: "",
                              icon: Icons.event_available,
                              color: ConfigurationApp.successColor,
                              textcolor: ConfigurationApp.whiteColor,
                            )),
                          ),
                        );
                      },
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: ListView(
                      children: [
                        //debit
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 60,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
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
                                      titre: "Total sychrinisée  ",
                                      number: dashList.isNotEmpty
                                          ? dashList[0]
                                                  ["sumMontantPeageRouteOnline"]
                                              .toString()
                                          : '0',
                                      signeIcon: "\$",
                                      icon: Icons.payments,
                                      color: ConfigurationApp.successColor,
                                      textcolor: ConfigurationApp.whiteColor,
                                    )),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 60,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
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
                                      titre: "Total en attente  ",
                                      number: dashList.isNotEmpty
                                          ? dashList[0][
                                                  "sumMontantPeageRouteOffLine"]
                                              .toString()
                                          : '0',
                                      signeIcon: "\$",
                                      icon: Icons.payment_sharp,
                                      color: ConfigurationApp.dangerColor,
                                      textcolor: ConfigurationApp.whiteColor,
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // fin
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Statistique globale"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          //appel statistique
                                          await getDashbord();
                                          await getListDataChart();
                                          await getMesVentes();
                                          await userList();
                                          // await isInteret();
                                        },
                                        child: const Text('Actualiser')),
                                  ],
                                )
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            color: Colors.white70,
                            height: 300,
                            child: charts.BarChart(
                              series,
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
                                      syncToMysqlPeageRoute();
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
