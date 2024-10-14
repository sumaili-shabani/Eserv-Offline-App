import 'dart:convert';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Page/Offline/PageOnLine/InsertData.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FetchArticle extends StatelessWidget {
  const FetchArticle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crud Complet App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyFetchListe(title: "My App crud basic"),
    );
  }
}

class MyFetchListe extends StatefulWidget {
  final String title;
  const MyFetchListe({Key? key, required this.title}) : super(key: key);

  @override
  State<MyFetchListe> createState() => _MyFetchListeState();
}

class _MyFetchListeState extends State<MyFetchListe> {
  List<dynamic> dataList = [];
  List<dynamic> dataSigleList = [];

  TextEditingController titleInput = TextEditingController();
  TextEditingController descriptionInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> viderCamps() async {
    setState(() {
      // dataList = data;
      titleInput.text = "";
      descriptionInput.text = "";
    });
  }

  Future<void> deleteData(int id) async {
    await CallApi.deleteData("delete_article", id);
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('${CallApi.ApiUrl}fetch_article_mobile'));

      if (response.statusCode == 200) {
        setState(() {
          dataList = jsonDecode(response.body)['data'];
        });
        // print(dataList);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchSigleData(int id) async {
    try {
      final response = await http
          .get(Uri.parse('${CallApi.ApiUrl}fetch_single_article/$id'));

      if (response.statusCode == 200) {
        setState(() {
          dataSigleList = jsonDecode(response.body)['data'];
        });
        print(dataSigleList);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> updateData(int id) async {
    var data = {
      "id": id,
      "title": titleInput.text,
      "description": descriptionInput.text,
    };

    await CallApi.insertOrUpdateData("insert_article", data);

    viderCamps();
    fetchData();
  }

  void showForm(int? id) async {
    if (id != null) {
      fetchSigleData(id);
      final existingjournal =
          dataSigleList.firstWhere((element) => element['id'] == id);
      titleInput.text = existingjournal['title'];
      descriptionInput.text = existingjournal['description'];
    }

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: titleInput,
                    decoration: const InputDecoration(
                      label: Text("Titre de l'article"),
                      prefixIcon: Icon(Icons.dashboard_customize_outlined),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionInput,
                    decoration: const InputDecoration(
                      label: Text("Description"),
                      prefixIcon: Icon(Icons.description),
                      // border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: () async {
                      if (id != null) {
                        await updateData(id);
                      }

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      fetchData();
                    },
                    label: Text(id == null ? 'Ajouter' : 'Modifier'),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (BuildContext context, int index) {
            final data = dataList[index];
            return Card(
              color: Colors.white,
              elevation: 1,
              child: ListTile(
                title: Text(
                  data['title'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data['description']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showForm(data['id']),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        deleteData(data['id']);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InsertData(),
            ),
          );
        },
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }
}
