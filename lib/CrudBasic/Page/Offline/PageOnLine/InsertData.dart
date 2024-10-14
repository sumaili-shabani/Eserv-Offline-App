import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Page/Offline/PageOnLine/FetchArticle.dart';
import 'package:flutter/material.dart';

class InsertData extends StatefulWidget {
  const InsertData({super.key});

  @override
  State<InsertData> createState() => _InsertDataState();
}

class _InsertDataState extends State<InsertData> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  Future<void> createData() async {
    try {
      var data = {
        "title": title.text,
        "description": description.text,
      };
      CallApi.insertOrUpdateData("insert_article", data);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FetchArticle(),
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajout des articles'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_membership),
            tooltip: 'Voir la liste des articles',
            onPressed: () {
              // handle the press
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(
                  label: Text("Titre de l'article"),
                  prefixIcon: Icon(Icons.dashboard_customize_outlined),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(
                  label: Text("Description"),
                  prefixIcon: Icon(Icons.description),
                  // border: OutlineInputBorder(),
                  hintMaxLines: 10,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 2,
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Ajouter"),
                onPressed: () {
                  createData();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
