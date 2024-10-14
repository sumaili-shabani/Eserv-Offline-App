import 'dart:convert';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String title = '';
  String description = '';

  //List<dynamic> dataList = [];
  List<Map<String, dynamic>> dataList = [];
  bool isloading = true;

  Future<void> retrieveData() async {
    final response =
        await http.get(Uri.parse('${CallApi.ApiUrl}fetch_article_mobile'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];

      setState(() {
        dataList = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Error retrieving data: ${response.body}');
    }
  }

  Future<void> _refreshRecord() async {
    final data = await retrieveData();
    setState(() {
      // dataList = data;
      isloading = false;
      viderCamps();
    });
  }

  Future<void> viderCamps() async {
    setState(() {
      // dataList = data;
      titleController.text = "";
      descriptionController.text = "";

      isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    //retrieveData();
  }

  Future<void> insertRecord() async {
    final title = titleController.text;
    final description = descriptionController.text;

    try {
      var svData = {
        "id": "",
        "title": title,
        "description": description,
      };

      CallApi.insertOrUpdateData("insert_article", svData);
      _refreshRecord();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> deleteRecord(int id) async {
    final int recordIdToDelete =
        id; // Replace with the ID of the record you want to delete
    CallApi.deleteData("delete_article", recordIdToDelete);
    _refreshRecord();
  }

  Future<void> updateRecord(int id) async {
    final int recordIdToDelete = id;
    final String title = titleController.text;
    final String description = descriptionController.text;

    if (id == 0 || title.isEmpty || description.isEmpty) {
      // Validation: Check if fields are not empty and ID is valid.
      CallApi.showErrorMsg('Please enter valid data.');
      return;
    }

    var svData = {
      "id": recordIdToDelete,
      "title": title,
      "description": description,
    };

    CallApi.showMsg(svData.toString());

    CallApi.insertOrUpdateData("insert_article", svData);
    _refreshRecord();
  }

  Future<void> updateData(int id) async {
    final int recordIdToDelete = id;
    final String title = titleController.text;
    final String description = descriptionController.text;
    final response =
        await http.put(Uri.parse('${CallApi.ApiUrl}/update_article/$id'),
            body: jsonEncode(<String, dynamic>{
              "id": recordIdToDelete,
              'title': title,
              'description': description,
            }));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      CallApi.showMsg(data.toString());
      _refreshRecord();
    } else {
      throw Exception('Failed to update data');
    }
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingjournal =
          dataList.firstWhere((element) => element['id'] == id);
      titleController.text = existingjournal['title'];
      descriptionController.text = existingjournal['description'];
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
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(hintText: 'description'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await insertRecord();
                      }
                      if (id != null) {
                        // await updateRecord(id);
                        await updateData(id);
                      }
                      titleController.text = '';
                      descriptionController.text = '';
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create new' : 'Update $id'),
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: insertRecord,
                child: const Text('Insert Record'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: retrieveData,
                child: const Text('Retrieve Data'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final item = dataList[index];
                    final id = item['id'];
                    final title = item['title'];
                    final description = item['description'];
                    return ListTile(
                      title: Text(
                        title.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      subtitle: Text(
                        description.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showForm(item['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteRecord(id);
                              },
                            )
                          ],
                        ),
                      ),
                      // You can customize the appearance of each list item as needed.
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
