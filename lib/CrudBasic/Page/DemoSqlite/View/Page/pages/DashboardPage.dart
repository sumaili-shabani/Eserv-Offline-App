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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
        body: Column(
      children: [
        const LayoutHeader(
            title: 'Tableau de bord',
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
                              color: ConfigurationApp.primaryColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Center(
                              child: CardDashboradComponent(
                            titre: "Cat taxation ",
                            number: dashList.isNotEmpty
                                ? dashList[0]["countCatTaxation"].toString()
                                : '0',
                            signeIcon: "",
                            icon: Icons.description,
                            color: ConfigurationApp.primaryColor,
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
                            titre: "Note déclarée  ",
                            number: dashList.isNotEmpty
                                ? dashList[0]["sumMontantTaxation"].toString()
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
                            titre: "Note sychrinisée  ",
                            number: dashList.isNotEmpty
                                ? dashList[0]["sumMontantTaxationOnline"]
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
                            titre: "Notes en attente  ",
                            number: dashList.isNotEmpty
                                ? dashList[0]["sumMontantTaxationOffLine"]
                                    .toString()
                                : '0',
                            signeIcon: "\$",
                            icon: Icons.payments,
                            color: ConfigurationApp.dangerColor,
                            textcolor: ConfigurationApp.whiteColor,
                          )),
                        ),
                      ),
                    ],
                  ),

                  //pour la globalité
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
                              color: ConfigurationApp.warningColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Center(
                              child: CardDashboradComponent(
                            titre: "Cb en attente",
                            number: dashList.isNotEmpty
                                ? dashList[0]["countCbOffline"].toString()
                                : '0',
                            signeIcon: "",
                            icon: Icons.badge,
                            color: ConfigurationApp.warningColor,
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
                              color: ConfigurationApp.successColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: Center(
                              child: CardDashboradComponent(
                            titre: "Total Cb",
                            number: dashList.isNotEmpty
                                ? dashList[0]["countCb"].toString()
                                : '0',
                            signeIcon: "",
                            icon: Icons.group_add,
                            color: ConfigurationApp.successColor,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Répartition par catégorie"),
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
                              child: const Text('Contribuable')),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: ConfigurationApp.successColor,
                          )
                        ],
                      )
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  color: Colors.white,
                  height: 80,
                  child: Column(children: [
                    //pour la globalité
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.42,
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
                              titre: "Cb P.Physique",
                              number: dashList.isNotEmpty
                                  ? dashList[0]["countCbPphysique"].toString()
                                  : '0',
                              signeIcon: "",
                              icon: Icons.group,
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
                                color: ConfigurationApp.successColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Center(
                                child: CardDashboradComponent(
                              titre: "Cb P.Morale",
                              number: dashList.isNotEmpty
                                  ? dashList[0]["countCbPmorale"].toString()
                                  : '0',
                              signeIcon: "",
                              icon: Icons.home_work,
                              color: ConfigurationApp.successColor,
                              textcolor: ConfigurationApp.whiteColor,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  color: Colors.white,
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: charts.BarChart(
                        series2,
                        animate: true,
                      ),
                    ),
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
