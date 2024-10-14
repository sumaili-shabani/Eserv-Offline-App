import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:flutter/material.dart';

class TempleteScreem extends StatefulWidget {
  const TempleteScreem({super.key});

  @override
  State<TempleteScreem> createState() => _TempleteScreemState();
}

class _TempleteScreemState extends State<TempleteScreem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const LayoutHeader(
            title: 'Templer', subTitle: "Description de screem templete"),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blue[200],
                  ),
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blue[200],
                  ),
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blue[200],
                  ),
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blue[200],
                  ),
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.blue[200],
                  ),
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: ListView(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Container(
              //             color: Colors.red,
              //             height: 100,
              //             width: MediaQuery.of(context).size.width * 0.3,
              //             child: const Center(
              //                 child: Text('Widget 1',
              //                     style: TextStyle(color: Colors.white))),
              //           ),
              //           Container(
              //             color: Colors.green,
              //             height: 100,
              //             width: MediaQuery.of(context).size.width * 0.3,
              //             child: const Center(
              //                 child: Text('Widget 2',
              //                     style: TextStyle(color: Colors.white))),
              //           ),
              //           Container(
              //             color: Colors.blue,
              //             height: 100,
              //             width: MediaQuery.of(context).size.width * 0.3,
              //             child: const Center(
              //                 child: Text('Widget 3',
              //                     style: TextStyle(color: Colors.white))),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(
              //         height: 10,
              //       ),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Container(
              //             color: Colors.red,
              //             height: 100,
              //             width: 120,
              //             child: const Center(
              //                 child: Text('Widget 4',
              //                     style: TextStyle(color: Colors.white))),
              //           ),
              //           Container(
              //             color: Colors.green,
              //             height: 100,
              //             width: 120,
              //             child: const Center(
              //                 child: Text('Widget 5',
              //                     style: TextStyle(color: Colors.white))),
              //           ),
              //           Container(
              //             color: Colors.blue,
              //             height: 100,
              //             width: 120,
              //             child: const Center(
              //                 child: Text('Widget 6',
              //                     style: TextStyle(color: Colors.white))),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(
              //         height: 10,
              //       ),
              //       const Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Text("Statistique globale"),
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.end,
              //               children: [
              //                 Text(
              //                   "Analyse",
              //                   style:
              //                       TextStyle(color: ConfigurationApp.successColor),
              //                 ),
              //                 Icon(Icons.arrow_forward_ios,
              //                     size: 13, color: ConfigurationApp.successColor),
              //               ],
              //             )
              //           ]),
              //       const SizedBox(
              //         height: 10,
              //       ),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         children: [
              //           SingleChildScrollView(
              //             child: Padding(
              //               padding: const EdgeInsets.all(8.0),
              //               child: Container(
              //                 color: Colors.red,
              //                 height: 100,
              //                 width: MediaQuery.of(context).size.width * 0.8,
              //                 child: const Center(
              //                     child: Text('Widget 1',
              //                         style: TextStyle(color: Colors.white))),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  color: Colors.red,
                  height: 200,
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  color: const Color.fromARGB(255, 232, 154, 149),
                  height: 200,
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  color: Colors.blue,
                  height: 200,
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  color: Colors.green[300],
                  height: 200,
                  child: const Center(
                      child: Text('Widget 1',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
