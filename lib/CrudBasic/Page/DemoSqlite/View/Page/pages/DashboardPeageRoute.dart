import 'dart:async';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/Components/bar_chart_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/CardDashBordComponent.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class DashboardPeageRoute extends StatefulWidget {
  const DashboardPeageRoute({super.key});

  @override
  State<DashboardPeageRoute> createState() => _DashboardPeageRouteState();
}

class _DashboardPeageRouteState extends State<DashboardPeageRoute> {
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
    print(dataStat);
  }

  @override
  void initState() {
    handler = DatabaseHelper();
    handler.initDB();
    super.initState();

    //appel statistique
    getDashbord();
    getListDataChart();
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
        body: Column(
      children: [
        const LayoutHeader(
            title: 'Tableau de bord péage route',
            subTitle: "Vue globale des opérations à jour dans le système!!!"),
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
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: ConfigurationApp.blackColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Center(
                              child: CardDashboradComponent(
                            titre: "Catégorie de taxe ",
                            number: dashList.isNotEmpty
                                ? dashList[0]["countCatTaxation"].toString()
                                : '0',
                            signeIcon: "",
                            icon: Icons.description,
                            color: ConfigurationApp.blackColor,
                            textcolor: ConfigurationApp.whiteColor,
                          )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.45,
                          decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: ConfigurationApp.blackColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Center(
                              child: CardDashboradComponent(
                            titre: "Total encaissé",
                            number: dashList.isNotEmpty
                                ? dashList[0]["sumMontantPeageRoute"].toString()
                                : '0',
                            signeIcon: "\$",
                            icon: Icons.person_pin_outlined,
                            color: ConfigurationApp.blackColor,
                            textcolor: ConfigurationApp.whiteColor,
                          )),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.45,
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
                                ? dashList[0]["sumMontantPeageRouteOnline"]
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
                          width: MediaQuery.of(context).size.width * 0.45,
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
                                ? dashList[0]["sumMontantPeageRouteOffLine"]
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
