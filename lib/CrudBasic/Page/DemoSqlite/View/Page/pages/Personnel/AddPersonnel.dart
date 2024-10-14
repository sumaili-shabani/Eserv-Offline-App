import 'dart:math';

import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/LayoutHeader.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Components/TextFildComponent.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPersonnel extends StatefulWidget {
  AddPersonnel(
      {this.noteId,
      this.fullName,
      this.email,
      this.usrName,
      this.usrPassword,
      this.idUser});
  final int? noteId;
  final String? fullName;
  final String? email;
  final String? usrName;
  final String? usrPassword;
  final String? idUser;

  @override
  State<AddPersonnel> createState() => _AddPersonnelState();
}

class _AddPersonnelState extends State<AddPersonnel> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final usrName = TextEditingController();
  final usrPassword = TextEditingController();
  final code = TextEditingController();
  final idUser = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ignore: non_constant_identifier_names, prefer_interpolation_to_compose_strings
  String CodeRandom = 'ref-${Random().nextInt(1000000)}';
  String toDay = '${DateFormat("yyyy-MM-dd hh:mm")}';

  final db = DatabaseHelper();
  late DatabaseHelper handler;

  bool editMode = false;

  @override
  void initState() {
    super.initState();

    handler = DatabaseHelper();

    if (widget.noteId != null) {
      editMode = true;
      fullName.text = widget.fullName.toString();
      usrName.text = widget.usrName.toString();
      usrPassword.text = widget.usrPassword.toString();
      email.text = widget.email.toString();
      idUser.text = widget.idUser.toString();
    } else {
      code.text = CodeRandom.toString();
    }
  }

  inserOrUpdateData() {
    //We should not allow empty data to the database
    if (formKey.currentState!.validate()) {
      if (editMode == true) {
        db
            .updateUser(fullName.text, usrName.text, email.text,
                usrPassword.text, int.parse(idUser.text), widget.noteId)
            .whenComplete(() {
          //After update, note will refresh

          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Modification avec succès!!!");
        });
      } else {
        db
            .createUserApp(Users(
                idRole: 9,
                usrName: usrName.text,
                fullName: fullName.text,
                email: email.text,
                password: usrPassword.text))
            .whenComplete(() {
          //When this value is true
          Navigator.of(context).pop(true);
          CallApi.showMsg("Insertion avec succès!!!");
        });
      }
    }
  }

  // synchronisation
  Future insertUserToOfflineApp() async {
    try {
      handler.getUserCountOnLineApp().whenComplete(() {
        //When this value is true
        Navigator.of(context).pop(true);
        CallApi.showMsg("Les utilisateurs sont bien importés avec succès!!!");
      });
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
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
            onPressed: () async {
              await handler.isInternet().then((connection) {
                if (connection) {
                  insertUserToOfflineApp();
                  print("Internet connection abailale");
                } else {
                  CallApi.showErrorMsg("Pas de connexion internet");
                }
              });
            },
            icon: const Icon(Icons.person_add),
            color: ConfigurationApp.blackColor,
            tooltip: "Importer les utilisateurs en ligne ",
          ),
          IconButton(
            onPressed: () {
              //Add Note button
              //We should not allow empty data to the database
              inserOrUpdateData();
            },
            icon: editMode ? const Icon(Icons.check) : const Icon(Icons.save),
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
                title: "Formulaire Utilisateur",
                subTitle:
                    "Cliquer sur un bouton afin d'effectuer une opération!!!"),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    //formulaire
                    TextFildComponent(
                      labeltext: "Nom Complet",
                      hint: "Entrez le nom complet",
                      icon: Icons.person,
                      controller: fullName,
                      validatorInput: true,
                    ),
                    TextFildComponent(
                        labeltext: "Non Utilisateur",
                        hint: "Entrez le non Utilisateur",
                        icon: Icons.badge,
                        controller: usrName,
                        validatorInput: true),
                    TextFildComponent(
                        labeltext: "E-mail",
                        hint: "Entrez l'adresse e-mail",
                        icon: Icons.email,
                        controller: email,
                        validatorInput: true),
                    TextFildComponent(
                      labeltext: "Mot de passe",
                      hint: "Entrez le mot de passe",
                      icon: Icons.lock,
                      controller: usrPassword,
                      validatorInput: true,
                    ),
                    editMode
                        ? TextFildComponent(
                            labeltext: "IdUser en ligne",
                            hint: "Id de l'utilisateur connecté",
                            icon: Icons.edit_note,
                            controller: idUser,
                            validatorInput: true,
                          )
                        : const Text(''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
