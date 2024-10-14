import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/note_model.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateNote extends StatefulWidget {
  CreateNote({this.title, this.content, this.code, this.noteId});
  final int? noteId;
  final String? title;
  final String? content;
  final String? code;

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final title = TextEditingController();
  final content = TextEditingController();
  final code = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ignore: non_constant_identifier_names, prefer_interpolation_to_compose_strings
  String CodeRandom = 'ref-${Random().nextInt(1000000)}';
  String toDay = '${DateFormat("yyyy-MM-dd hh:mm")}';

  final db = DatabaseHelper();

  bool editMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.noteId != null) {
      editMode = true;
      title.text = widget.title.toString();
      content.text = widget.content.toString();
      code.text = widget.code.toString();
    } else {
      code.text = CodeRandom.toString();
    }
  }

  inserOrUpdateData() {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
        db.updateNote(title.text, content.text, widget.noteId).whenComplete(() {
          //After update, note will refresh

          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Modification avec succès!!!");
        });
      } else {
        db
            .createNote(NoteModel(
                noteEtat: 0,
                noteTitle: title.text,
                noteContent: content.text,
                noteCode: code.text,
                createdAt: DateTime.now().toIso8601String()))
            .whenComplete(() {
          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Insertion avec succès!!!");
        });
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
          IconButton(
              onPressed: () {
                //Add Note button
                //We should not allow empty data to the database
                inserOrUpdateData();
              },
              icon: editMode ? const Icon(Icons.check) : const Icon(Icons.save))
        ],
      ),
      body: Form(
          //I forgot to specify key
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextFormField(
                  controller: title,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "ce champs est requis";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.book),
                    label: Text("Le titre"),
                  ),
                ),
                TextFormField(
                  controller: content,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Ce champs est requis";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.description),
                    label: Text("Description"),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                ),
                // TextFormField(
                //   controller: code,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return "code note is required";
                //     }
                //     return null;
                //   },
                //   decoration: const InputDecoration(
                //     prefixIcon: Icon(Icons.code),
                //     label: Text("Code note"),
                //   ),
                // ),
              ],
            ),
          )),
    );
  }
}
