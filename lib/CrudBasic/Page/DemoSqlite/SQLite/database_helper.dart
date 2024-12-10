import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/Components/bar_chart_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/PeageModel.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/Taxation_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/categoryTaxe_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/contribuable_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/detailTaxation_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/immatriculationModel.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/note_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';

//pour voir l'endroid ou se trouve la base des données
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  //mes scripts

  //fin scripts
  final databaseName = "note_db12.db";
  String noteTable =
      "CREATE TABLE IF NOT EXISTS notes (noteId INTEGER PRIMARY KEY AUTOINCREMENT,noteEtat INTEGER NOT NULL, noteTitle TEXT NOT NULL, noteContent TEXT NOT NULL, noteCode  TEXT, createdAt TEXT DEFAULT CURRENT_TIMESTAMP)";

  //Don't put a comma at the end of a column in sqlite

  String users = '''
   CREATE TABLE IF NOT EXISTS users (
   usrId INTEGER PRIMARY KEY AUTOINCREMENT,
   id INTEGER,
   idRole INTEGER DEFAULT 9,
   fullName TEXT,
   email TEXT,
   usrName TEXT UNIQUE,
   usrPassword TEXT

   )
   ''';

  String contibuables = '''
   CREATE TABLE IF NOT EXISTS contibuables (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    typeCb	Text,
    idtypeCb	INTEGER NOT NULL DEFAULT 1,
    nomCompletCb	Text,
    telCb	Text,
    telsmsCb	Text,
    sexeCb	Text,
    imageCb	Text DEFAULT 'avatar.png',
    nomEts	Text,
    respoEts	Text,
    idAvenue	INTEGER DEFAULT 1,
    numero_maisonCb	Text,
    etatCb	INTEGER DEFAULT 0,
    codeCb	Text,
    createdAt	Text DEFAULT CURRENT_TIMESTAMP

   )

   ''';

  String categoryTaxes = '''

  CREATE TABLE IF NOT EXISTS category_taxes (
    idCatTaxe INTEGER PRIMARY KEY AUTOINCREMENT,
    id INTEGER,
    idSousLibelle INTEGER,
    nomCatTaxe TEXT,
    taux_personnel TEXT,
    taux_morale TEXT,
    periode TEXT,
    jourEcheance TEXT,
    date_debit TEXT,
    date_fin TEXT,
    forme_calcul TEXT,
    type_taux TEXT,
    createdAt	Text DEFAULT CURRENT_TIMESTAMP
  )

   ''';

  String taxationTable = '''
  CREATE TABLE  taxations (
    idTaxation INTEGER PRIMARY KEY AUTOINCREMENT,
    idCompteBancaire INTEGER DEFAULT 1,
    etatNoteSync INTEGER DEFAULT 0,
    statut INTEGER DEFAULT 0,
    payementStatut INTEGER DEFAULT 0,
    idCb INTEGER ,
    idUser INTEGER,
    devise TEXT,
    anneeFiscale TEXT,
    codeNote TEXT UNIQUE,
    comment TEXT,
    dateTaxation TEXT,
    createdAt	Text DEFAULT CURRENT_TIMESTAMP
  )

   ''';

  String detailTaxationTable = '''
  CREATE TABLE  detail_taxations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idTaxation INTEGER,
    idCatTaxe INTEGER,
    idUser INTEGER,
    groupeCat INTEGER DEFAULT 1,
    idAvenue INTEGER DEFAULT 1,
    periode TEXT,
    date_periode_debit TEXT,
    date_periode_fin TEXT,
    pu INTEGER  DEFAULT 0,
    qte INTEGER  DEFAULT 0,
    montant_cdf INTEGER  DEFAULT 0,
    montant_usd INTEGER  DEFAULT 0,
    montant_reel INTEGER  DEFAULT 0,
    commentaire TEXT,
    numero_maison TEXT,
    locataire TEXT,
    dateContrat_debit TEXT,
    dateContrat_fin TEXT,
    nbr_mois TEXT,
    num_chassie TEXT,
    propriete_place TEXT,
    passager TEXT,
    photo TEXT,
    codeNote TEXT,
    createdAt	Text DEFAULT CURRENT_TIMESTAMP
  )

   ''';

  String immatriculationTable = '''

  CREATE TABLE IF NOT EXISTS immatriculation (
    idImmatriculation INTEGER PRIMARY KEY AUTOINCREMENT,
    idLibelle INTEGER,
    idSousLibelle INTEGER,
    nomSousLibelle TEXT,
    createdAt	Text DEFAULT CURRENT_TIMESTAMP
  )

   ''';

  String peageTable = '''

  CREATE TABLE IF NOT EXISTS peage (
    idPeage INTEGER PRIMARY KEY AUTOINCREMENT,
    idCatTaxe INTEGER,
    idUser INTEGER,
    statutPeage INTEGER  DEFAULT 0,
    qte INTEGER  DEFAULT 0,
    pu double  DEFAULT 0,
    montantUsd double  DEFAULT 0,
    nomAgent TEXT,
    nomCb TEXT,
    telCb TEXT,
    marqueVehicule TEXT,
    modelVehicule TEXT,
    chassieVehicule TEXT,
    numPlaque TEXT,
    devise TEXT,
    datePaiement TEXT,
    codeNote TEXT,
    comment TEXT,
    nomCatTaxe TEXT DEFAULT 'peage',
    createdAt	Text DEFAULT CURRENT_TIMESTAMP
  )

   ''';

  //We are done in this section

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(taxationTable);
      await db.execute(detailTaxationTable);
      await db.execute(users);
      await db.execute(noteTable);
      await db.execute(contibuables);
      await db.execute(categoryTaxes);
      await db.execute(immatriculationTable);
      await db.execute(peageTable);
    });
  }

  Future<Database> openDatabaseFromAssets2() async {
    // Get the temporary directory (cache)
    final directory = await getTemporaryDirectory();
    final path = join(directory.path, 'demo.db');

    // Check if the database file exists
    final exists = await File(path).exists();

    if (!exists) {
      // Copy from assets
      ByteData data = await rootBundle.load('assets/db/demo.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Open the database
    return await openDatabase(path);
  }

  Future<Database> openDatabaseFromAssets(String dbName) async {
    // PROBLEM IS WITH THIS LINE
    final directory = await getTemporaryDirectory();

    final path = join(directory.path, dbName);

    // Check if the database file exists
    final exists = await File(path).exists();

    if (!exists) {
      // Copy from assets
      ByteData data = await rootBundle.load('assets/db/$dbName');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    }

    // Open the database
    return await openDatabase(path);
  }

  /*
  *
  *===================
  *Dashboard
  *===================
  */

  Future deleteQueryDatatable(String table) async {
    final Database db = await initDB();
    return db.delete('$table ');
  }

  Future getQueryCount(String table) async {
    final Database db = await initDB();
    int count = 0;
    try {
      List<Map<String, dynamic>> maps =
          await db.rawQuery("select COUNT(*) as count from $table ");

      for (var item in maps) {
        count = item["count"];
        // print('count: ${item["count"]}');
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return count;
  }

  Future getQueryCountTableWhere(String table, String column, value) async {
    final Database db = await initDB();
    int count = 0;
    try {
      List<Map<String, dynamic>> maps = await db.rawQuery(
          "select COUNT(*) as count from $table where $column=? ", [value]);

      for (var item in maps) {
        count = item["count"];
        // print('count: ${item["count"]}');
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return count;
  }

  //pour la sommation
  Future getQuerySum(String table, String column) async {
    final Database db = await initDB();
    int sum = 0;
    try {
      List<Map<String, dynamic>> maps =
          await db.rawQuery("select SUM($column) as sum from $table ");

      for (var item in maps) {
        sum = item["sum"];
        // print('sum: ${item["sum"]}');
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return sum;
  }

  //pour la sommation
  Future getQuerySommePeageRoute() async {
    final Database db = await initDB();
    int sum = 0;
    double doublePeage = 0;
    try {
      List<Map<String, dynamic>> maps = await db.rawQuery(
          "select SUM(montantUsd) as sum, datePaiement from peage  where datePaiement > DATETIME('now', '-30 day') ");

      for (var item in maps) {
        doublePeage = item["sum"];
        sum = int.parse(doublePeage.toStringAsFixed(0));
        // print('la soomme est: ${sum}');
        // print(item);
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return sum;
  }

  Future getQuerySumWhere(
      String table, String columnNumber, String column, value) async {
    final Database db = await initDB();
    int sum = 0;
    try {
      List<Map<String, dynamic>> maps = await db.rawQuery(
          "select SUM($columnNumber) as sum from $table where $column=? ",
          [value]);

      for (var item in maps) {
        sum = item["sum"];
        // print('sum: ${item["sum"]}');
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return sum;
  }

  Future getQuerySumTaxation(value) async {
    final Database db = await initDB();
    int sum = 0;
    try {
      List<Map<String, dynamic>> maps = await db.rawQuery(
          "select SUM(detail_taxations.montant_reel) as sum from detail_taxations inner join taxations  on detail_taxations.idTaxation=taxations.idTaxation  where taxations.etatNoteSync=? and taxations.dateTaxation > DATETIME('now', '-30 day') ",
          [value]);

      for (var item in maps) {
        sum = item["sum"];
        // print('sum: ${item["sum"]}');
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return sum;
  }

  Future getQuerySumPeageRoute(value) async {
    final Database db = await initDB();
    int sum = 0;
    double montantUsd = 0;
    try {
      List<Map<String, dynamic>> maps = await db.rawQuery(
          "select SUM(montantUsd) as sum, datePaiement from peage  where statutPeage=? and datePaiement > DATETIME('now', '-30 day') ",
          [value]);

      for (var item in maps) {
        montantUsd = item["sum"];
        sum = int.parse(montantUsd.toStringAsFixed(0));
        // print('sum: ${item["sum"]}');
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return sum;
  }

  Future<List<BarChartModel>> getStatistiqueTaxation(String column) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery(
        "select SUM(detail_taxations.montant_reel) as financial, taxations.dateTaxation as year, contibuables.typeCb, contibuables.idtypeCb from detail_taxations inner join taxations  on detail_taxations.idTaxation=taxations.idTaxation  inner join contibuables  on contibuables.id=taxations.idCb  WHERE taxations.dateTaxation > DATETIME('now', '-30 day') group by $column");
    return result.map((e) => BarChartModel.fromMap(e)).toList();
  }

  Future getListStatistiqueTaxation(String column) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery(
        "select SUM(detail_taxations.montant_reel) as financial, taxations.dateTaxation as year, contibuables.typeCb, contibuables.idtypeCb from detail_taxations inner join taxations  on detail_taxations.idTaxation=taxations.idTaxation  inner join contibuables  on contibuables.id=taxations.idCb  WHERE taxations.dateTaxation > DATETIME('now', '-30 day') group by $column ORDER BY detail_taxations.id desc");
    List datas = [];

    for (var item in result) {
      datas.add(item);
    }
    return datas;
  }

  /*
  *
  *===================
  * Fin Dashboard
  *===================
  */

  /*
  *
  *=======================
  * Table User SGBD
  *=======================
  */

  //Function methods

  //Authentication
  Future<bool> authenticate(Users usr) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "select * from users where usrName = '${usr.usrName}' AND usrPassword = '${usr.password}' And id is not null LIMIT 1");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future authenticateConnected(Users usr) async {
    final Database db = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await db.rawQuery(
          "select * from users where usrName = '${usr.usrName}' AND usrPassword = '${usr.password}' And id is not null LIMIT 1");

      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }

    return userList;
  }

  Future<bool> authenticateOffline(Users usr) async {
    final Database db = await openDatabaseFromAssets('demo.db');

    var result = await db.rawQuery(
        "select * from users where usrName = '${usr.usrName}' AND usrPassword = '${usr.password}' ");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //Sign up
  Future<int> createUser(Users usr) async {
    final Database db = await initDB();
    return db.insert("users", usr.toMap());
  }

  //Get current User details
  Future<Users?> getUser(String usrName) async {
    final Database db = await initDB();
    var res = await db
        .query("users", where: "usrName = ? LIMIT 1", whereArgs: [usrName]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  /*
  *
  *=======================
  * Table User SGBD
  *=======================
  */

  Future fetchDataListUser() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('select * from users order by usrId desc limit 1000');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future getUserCountOnLineApp() async {
    final Database dbClient = await initDB();
    //liste des utilisateur on line
    List userOnLineAppList = [];

    try {
      //requete
      final response = await http
          .get(Uri.parse('${CallApi.ApiUrl}fetch_user_to_offline_app'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];
        // userOnLineAppList = List<Map<String, dynamic>>.from(data);
        userOnLineAppList = data;

        // print(userOnLineAppList);

        //boucle
        for (var i = 0; i < userOnLineAppList.length; i++) {
          Map<String, dynamic> data = {
            "id": userOnLineAppList[i]['id'].toString(),
            "idRole": userOnLineAppList[i]['id_role'].toString(),
            "fullName": userOnLineAppList[i]['name'].toString(),
            "email": userOnLineAppList[i]['email'].toString(),
            "usrName": userOnLineAppList[i]['name'].toString(),
            "usrPassword": userOnLineAppList[i]['usrPassword'].toString(),
          };

          var countUser = getUserExist(int.parse(data['id']));
          if (countUser == true) {
            // CallApi.showMsg("${data['id']} il existe");
          } else {
            // CallApi.showMsg("Pret pour inserer le ${data['id']}");
            await dbClient.insert('users', data);
          }

          // print('countUser: ${data["id"]}');
        }
      } else {
        print('Error retrieving data: ${response.body}');
      }
    } catch (e) {
      CallApi.showErrorMsg(e.toString());
      print(e.toString());
    }
  }

  Future getUserExist(int id) async {
    final Database db = await initDB();
    var result = await db.rawQuery("select * from users where id= $id ");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> DropTableIfExistsThenReCreate() async {
    final Database db = await initDB();

    await db.execute("DROP TABLE IF EXISTS users");
    await db.execute(users);
  }

  // ignore: non_constant_identifier_names
  Future<void> DropTableIfExistsThenReCreateCattaxe() async {
    final Database db = await initDB();

    await db.execute("DROP TABLE IF EXISTS category_taxes");
    await db.execute(categoryTaxes);
  }

  // ignore: non_constant_identifier_names
  Future<void> DropTableIfExistsThenReCreateTaxation() async {
    final Database db = await initDB();

    await db.execute("DROP TABLE IF EXISTS taxations");
    await db.execute(taxationTable);
  }

  // ignore: non_constant_identifier_names
  Future<void> DropTableIfExistsThenReCreateDetailTaxation() async {
    final Database db = await initDB();

    await db.execute("DROP TABLE IF EXISTS detail_taxations");
    await db.execute(detailTaxationTable);
  }

  //crud

  //Get users
  Future<List<Users>> fetchUsers() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result =
        await db.rawQuery('select * from users order by usrId desc');
    return result.map((e) => Users.fromMap(e)).toList();
  }

  // recherche des utilisateurs
  Future<List<Users>> searchUsers(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from users where fullName like ? or usrName like ?",
        ["%$keyword%", "%$keyword%"]);
    return searchResult.map((e) => Users.fromMap(e)).toList();
  }

  //Delete user
  Future<int> deleteUser(int id) async {
    final Database db = await initDB();
    return db.delete('users', where: 'usrId = ?', whereArgs: [id]);
  }

  Future<int> createUserApp(Users user) async {
    final Database db = await initDB();
    return db.insert('users', user.toMap());
  }

  Future<int> updateUser(
      fullName, usrName, email, usrPassword, idUser, usrId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update users set fullName = ?, usrName = ? , email = ? , usrPassword = ?, id = ?  where usrId = ?',
        [fullName, usrName, email, usrPassword, idUser, usrId]);
  }

  /*
  *
  *=======================
  * Table User SGBD
  *=======================
  */

  /*
  *
  *=======================
  * Table notes SGBD
  *=======================
  */

  //CRUD Methods
  //Search Method
  Future<List<NoteModel>> searchNotes(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db
        .rawQuery("select * from notes where noteTitle LIKE ?", ["%$keyword%"]);
    return searchResult.map((e) => NoteModel.fromMap(e)).toList();
  }

  //Create Note
  Future<int> createNote(NoteModel note) async {
    final Database db = await initDB();
    return db.insert('notes', note.toMap());
  }

  //Get notes
  Future<List<NoteModel>> getNotes() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result =
        await db.rawQuery('select * from notes order by noteId desc');
    return result.map((e) => NoteModel.fromMap(e)).toList();
  }

  //Delete Notes
  Future<int> deleteNote(int id) async {
    final Database db = await initDB();
    return db.delete('notes', where: 'noteId = ?', whereArgs: [id]);
  }

  //Update Notes
  Future<int> updateNote(title, content, noteId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update notes set noteTitle = ?, noteContent = ? where noteId = ?',
        [title, content, noteId]);
  }

  //Update Notes
  Future<int> updateEtatNote(noteEtat, noteId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update notes set noteEtat = ? where noteId = ?', [noteEtat, noteId]);
  }

  /*
  *
  *=======================
  * Table contribuable SGBD
  *=======================
  */

  //CRUD Methods
  //Search Method
  //Search Method
  Future<List<ContribuableModel>> searchCb(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from contibuables where nomCompletCb LIKE ? or nomEts like ?",
        ["%$keyword%", "%$keyword%"]);
    return searchResult.map((e) => ContribuableModel.fromMap(e)).toList();
  }

  //Create Note
  Future<int> createCb(ContribuableModel note) async {
    final Database db = await initDB();
    return db.insert('contibuables', note.toMap());
  }

  //Get notes
  Future<List<ContribuableModel>> getCb() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result =
        await db.rawQuery('select * from contibuables order by id desc');
    return result.map((e) => ContribuableModel.fromMap(e)).toList();
  }

  //Delete Notes
  Future<int> deleteCb(int id) async {
    final Database db = await initDB();
    return db.delete('contibuables', where: 'id = ?', whereArgs: [id]);
  }

  //Update Notes
  Future<int> updateCb(
      String nomCompletCb,
      String telCb,
      String telsmsCb,
      String sexeCb,
      String nomEts,
      String respoEts,
      String numeroMaisonCb,
      id) async {
    final Database db = await initDB();

    return db.rawUpdate(
        "update contibuables set  nomCompletCb=?, telCb=?,telsmsCb=?, sexeCb=?,  nomEts=?, respoEts=?,  numero_maisonCb=? where id=?",
        [
          nomCompletCb,
          telCb,
          telsmsCb,
          sexeCb,
          nomEts,
          respoEts,
          numeroMaisonCb,
          id
        ]);
  }

  Future<int> updateCbPartie2(
      String nomCompletCb,
      String telCb,
      String telsmsCb,
      String nomEts,
      String respoEts,
      String numeroMaisonCb,
      id) async {
    final Database db = await initDB();

    return db.rawUpdate(
        "update contibuables set  nomCompletCb=?, telCb=?,telsmsCb=?, nomEts=?, respoEts=?, numero_maisonCb=? where id=?",
        [nomCompletCb, telCb, telsmsCb, nomEts, respoEts, numeroMaisonCb, id]);
  }

  //Update Notes
  Future<int> updateEtatCb(etatCb, id) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update contibuables set etatCb = ? where id = ?', [etatCb, id]);
  }

  Future<int> updateInitStoreEtatCb() async {
    final Database db = await initDB();
    return db.rawUpdate('update contibuables set etatCb =0 ');
  }

  Future fetchDataListCb() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from contibuables where etatCb=? order by id desc limit 1000',
          [0]);
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future fetchAllDataListCb() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('select * from contibuables order by id desc limit 5000');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future fetchDataListAllCb() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('select * from contibuables order by id desc limit 1000');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future fetchDataListAllCbSigle(id) async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from contibuables where id=? order by id desc limit 1',
          [id]);
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future<List<ContribuableModel>> fetchAllInfoCb() async {
    final Database dbClient = await initDB();
    List<ContribuableModel> blogList = [];
    try {
      List<Map<String, Object?>> maps = await dbClient
          .rawQuery('select * from contibuables order by id desc limit 1000');

      for (var item in maps) {
        blogList.add(ContribuableModel.fromMap(item));
      }
    } catch (e) {
      print(e.toString());
    }
    return blogList;
  }

  //pour la synchronisation
  Future saveToMysqlCb(List dataList) async {
    for (var i = 0; i < dataList.length; i++) {
      Map<String, dynamic> data = {
        "id": "",
        "typeCb": dataList[i]['typeCb'].toString(),
        "idtypeCb": dataList[i]['idtypeCb'].toString(),
        "nomCompletCb": dataList[i]['nomCompletCb'].toString(),
        "telCb": dataList[i]['telCb'].toString(),
        "telsmsCb": dataList[i]['telsmsCb'].toString(),
        "sexeCb": dataList[i]['sexeCb'].toString(),
        "imageCb": dataList[i]['imageCb'].toString(),
        "nomEts": dataList[i]['nomEts'].toString(),
        "respoEts": dataList[i]['respoEts'].toString(),
        "idAvenue": dataList[i]['idAvenue'].toString(),
        "numero_maisonCb": dataList[i]['numero_maisonCb'].toString(),
        "etatCb": dataList[i]['etatCb'].toString(),
        "codeCb": dataList[i]['codeCb'].toString(),
      };
      // print(data);
      insertQueryBDonLineCb("insert_cb_mobile", data, dataList[i]['id']);
    }
  }

  Future insertQueryBDonLineCb(String url, Map svData, int id) async {
    try {
      final String dataState;
      final res = await http.post(
          Uri.parse("${CallApi.ApiUrl.toString()}insert_cb_mobile"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(svData));

      if (res.statusCode == 200) {
        dataState = jsonDecode(res.body)['dataState'].toString();
        var message = jsonDecode(res.body)['data'].toString();
        if (dataState == "1") {
          //changement d'etat de cb envoyé au serveur
          updateEtatCb(1, id);

          CallApi.showMsg(message);
        }
      } else {
        dataState = "0";
      }
    } catch (e) {
      CallApi.showErrorMsg(e.toString());
    }
  }

  /*
  *
  *=======================
  * FIN Table contribuable SGBD
  *=======================
  */

  /*
  *
  *================================
  * La synchronisation
  *================================
  *
  */
  Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (await DataConnectionChecker().hasConnection) {
        print("Mobile data detected & internet connection confirmed.");
        return true;
      } else {
        print('No internet :( Reason:');
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (await DataConnectionChecker().hasConnection) {
        print("wifi data detected & internet connection confirmed.");
        return true;
      } else {
        print('No internet :( Reason:');
        return false;
      }
    } else {
      print(
          "Neither mobile data or WIFI detected, not internet connection found.");
      return false;
    }
  }

  Future fetchDataList() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from notes where noteEtat=? order by noteId desc limit 200',
          [0]);
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future<List<NoteModel>> fetchAllInfo() async {
    final Database dbClient = await initDB();
    List<NoteModel> blogList = [];
    try {
      List<Map<String, Object?>> maps =
          await dbClient.rawQuery('select * from notes order by noteId desc');

      for (var item in maps) {
        blogList.add(NoteModel.fromMap(item));
      }
    } catch (e) {
      print(e.toString());
    }
    return blogList;
  }

  Future insertQueryBDonLine(String url, Map svData, int noteId) async {
    try {
      final String dataState;
      final res = await http.post(
          Uri.parse("${CallApi.ApiUrl.toString()}insert_article_mobile"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(svData));

      if (res.statusCode == 200) {
        dataState = jsonDecode(res.body)['dataState'].toString();
        var message = jsonDecode(res.body)['data'].toString();
        if (dataState == "1") {
          updateEtatNote(1, noteId);

          CallApi.showMsg(message);
        }
      } else {
        dataState = "0";
      }
    } catch (e) {
      CallApi.showErrorMsg(e.toString());
    }
  }

  //pour la synchronisation
  Future saveToMysql(List dataList) async {
    for (var i = 0; i < dataList.length; i++) {
      Map<String, dynamic> data = {
        "id": "",
        "noteId": dataList[i]['noteId'].toString(),
        "title": dataList[i]['noteTitle'].toString(),
        "description": dataList[i]['noteContent'].toString(),
        "code": dataList[i]['noteCode'],
      };

      insertQueryBDonLine("insert_article_mobile", data, dataList[i]['noteId']);
    }
  }

  /*
  *
  *=======================
  * Table User SGBD
  *=======================
  */

  /*
  *
  *=========================
  * Category Taxe
  *=========================
  */
  //show categorie list
  Future fetchDataListCatTaxe() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from category_taxes order by idCatTaxe desc limit 10000');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future getCatTaxeSelected(int id) async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('select * from category_taxes where id=?  limit 1', [id]);
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future getCatTaxeSelectedByImmatriculation(int idSousLibelle) async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from category_taxes where idSousLibelle=?',
          [idSousLibelle]);
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  //Get users
  Future<List<CategoryTaxeModel>> fetchCatTaxe() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db
        .rawQuery('select * from category_taxes order by idCatTaxe desc');
    return result.map((e) => CategoryTaxeModel.fromMap(e)).toList();
  }

  // recherche des utilisateurs
  Future<List<CategoryTaxeModel>> searchCategories(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from category_taxes where nomCatTaxe like ? or id like ?",
        ["%$keyword%", "%$keyword%"]);
    return searchResult.map((e) => CategoryTaxeModel.fromMap(e)).toList();
  }

  //Delete user
  Future<int> deleteCatTaxe(int id) async {
    final Database db = await initDB();
    return db.delete('category_taxes', where: 'idCatTaxe = ?', whereArgs: [id]);
  }

  Future<int> createCatTaxe(CategoryTaxeModel user) async {
    final Database db = await initDB();
    return db.insert('category_taxes', user.toMap());
  }

  Future<int> updateCatTaxe(
      nomCatTaxe,
      taux_personnel,
      taux_morale,
      periode,
      jourEcheance,
      date_debit,
      date_fin,
      forme_calcul,
      type_taux,
      id,
      idCatTaxe) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update category_taxes set nomCatTaxe=?, taux_personnel=?, taux_morale=?, periode=?, jourEcheance=?, date_debit=?, date_fin=?, forme_calcul=?, type_taux=?, id=?  where idCatTaxe = ?',
        [
          nomCatTaxe,
          taux_personnel,
          taux_morale,
          periode,
          jourEcheance,
          date_debit,
          date_fin,
          forme_calcul,
          type_taux,
          id,
          idCatTaxe
        ]);
  }

  Future getCatTaxtExist(int id) async {
    final Database db = await initDB();
    var result =
        await db.rawQuery("select * from category_taxes where id= $id ");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //get Taxe on line app
  Future getTaxeOnLineApp() async {
    final Database dbClient = await initDB();
    //liste des utilisateur on line
    List userOnLineAppList = [];

    try {
      //requete
      final response = await http
          .get(Uri.parse('${CallApi.ApiUrl}get_cat_taxe_put_to_mobile_app'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];

        userOnLineAppList = data;

        //boucle
        for (var i = 0; i < userOnLineAppList.length; i++) {
          Map<String, dynamic> data = {
            "id": userOnLineAppList[i]['id'].toString(),
            "idSousLibelle": userOnLineAppList[i]['idSousLibelle'].toString(),
            "nomCatTaxe": userOnLineAppList[i]['nomCatTaxe'].toString(),
            "taux_personnel": userOnLineAppList[i]['taux_personnel'].toString(),
            "taux_morale": userOnLineAppList[i]['taux_morale'].toString(),
            "periode": userOnLineAppList[i]['periode'].toString(),
            "jourEcheance": userOnLineAppList[i]['jourEcheance'].toString(),
            "date_debit": userOnLineAppList[i]['date_debit'].toString(),
            "date_fin": userOnLineAppList[i]['date_fin'].toString(),
            "forme_calcul": userOnLineAppList[i]['forme_calcul'].toString(),
            "type_taux": userOnLineAppList[i]['type_taux'].toString(),
          };

          var countUser = getCatTaxtExist(int.parse(data['id']));
          if (countUser == true) {
            // CallApi.showMsg("la cat de taxe: ${data['id']} il existe");
          } else {
            // CallApi.showMsg("Pret pour inserer le ${data['id']}");
            await dbClient.insert('category_taxes', data);
          }

          // print('countUser: ${data["id"]}');
        }
      } else {
        print('Error retrieving data: ${response.body}');
      }
    } catch (e) {
      CallApi.showErrorMsg(e.toString());
      print(e.toString());
    }
  }

  /*
  *
  *=========================
  * Category Taxe
  *=========================
  */

  /*
  *
  *=========================
  * Taxation
  *=========================
  */

  //show categorie list
  Future fetchDataListTaxation() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select contibuables.codeCb, taxations.idTaxation, taxations.idCompteBancaire, taxations.etatNoteSync, taxations.statut, taxations.payementStatut, taxations.idCb, taxations.idUser, taxations.devise, taxations.anneeFiscale, taxations.codeNote, taxations.comment, taxations.dateTaxation, taxations.createdAt from taxations inner join contibuables on taxations.idCb=contibuables.id where taxations.etatNoteSync=0 and taxations.statut=1 order by taxations.idTaxation desc');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  //Get users
  Future<List<TaxationModel>> fetchTaxation() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery(
        'select taxations.idTaxation, taxations.idCompteBancaire,taxations.etatNoteSync,taxations.idCb, taxations.idUser,taxations.devise,taxations.anneeFiscale,taxations.codeNote, taxations.statut,taxations.payementStatut,taxations.comment,taxations.dateTaxation, taxations.createdAt, contibuables.nomCompletCb,contibuables.idtypeCb,contibuables.typeCb, contibuables.nomEts from taxations inner join contibuables on taxations.idCb=contibuables.id order by taxations.idTaxation desc');
    // List<Map<String, Object?>> result = await db
    //     .rawQuery('select * FROM taxations order by taxations.idTaxation desc');
    return result.map((e) => TaxationModel.fromMap(e)).toList();
  }

  //pour le cb
  Future fetchTaxationCb(idCb) async {
    final Database db = await initDB();
    List<TaxationModel> userList = [];
    try {
      List<Map<String, Object?>> maps = await db.rawQuery(
          'select taxations.idTaxation, taxations.idCompteBancaire,taxations.etatNoteSync,taxations.idCb, taxations.idUser,taxations.devise,taxations.anneeFiscale,taxations.codeNote, taxations.statut,taxations.payementStatut,taxations.comment,taxations.dateTaxation, taxations.createdAt, contibuables.nomCompletCb,contibuables.idtypeCb,contibuables.typeCb, contibuables.nomEts from taxations inner join contibuables on taxations.idCb=contibuables.id where taxations.idCb=$idCb order by taxations.idTaxation desc');
      for (var map in maps) {
        userList.add(TaxationModel(
          idTaxation: int.parse(map["idTaxation"].toString()),
          idCompteBancaire: int.parse(map["idCompteBancaire"].toString()),
          etatNoteSync: int.parse(map["etatNoteSync"].toString()),
          idCb: int.parse(map["idCb"].toString()),
          idUser: int.parse(map["idUser"].toString()),
          devise: map["devise"].toString(),
          anneeFiscale: map["anneeFiscale"].toString(),
          codeNote: map["codeNote"].toString(),
          statut: int.parse(map["statut"].toString()),
          payementStatut: int.parse(map["payementStatut"].toString()),
          comment: map["comment"].toString(),
          nomCompletCb: map["nomCompletCb"].toString(),
          nomEts: map["nomEts"].toString(),
          dateTaxation: map["dateTaxation"].toString().toString(),
          idtypeCb: int.parse(map["idtypeCb"].toString()),
          typeCb: map["typeCb"].toString(),
          createdAt: map["createdAt"].toString(),
        ));
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future searchTaxationsCb(String keyword, idCb) async {
    final Database db = await initDB();
    List<TaxationModel> userList = [];
    try {
      List<Map<String, Object?>> maps = await db.rawQuery(
          "select taxations.idTaxation, taxations.idCompteBancaire,taxations.etatNoteSync,taxations.idCb, taxations.idUser,taxations.devise,taxations.anneeFiscale,taxations.codeNote, taxations.statut,taxations.payementStatut,taxations.comment,taxations.dateTaxation, taxations.createdAt, contibuables.nomCompletCb,contibuables.idtypeCb,contibuables.typeCb, contibuables.nomEts from taxations inner join contibuables on taxations.idCb=contibuables.id where taxations.codeNote like ? or contibuables.nomCompletCb like ? or contibuables.nomEts like ? and taxations.idCb=$idCb",
          ["%$keyword%", "%$keyword%", "%$keyword%"]);
      for (var map in maps) {
        userList.add(TaxationModel(
          idTaxation: int.parse(map["idTaxation"].toString()),
          idCompteBancaire: int.parse(map["idCompteBancaire"].toString()),
          etatNoteSync: int.parse(map["etatNoteSync"].toString()),
          idCb: int.parse(map["idCb"].toString()),
          idUser: int.parse(map["idUser"].toString()),
          devise: map["devise"].toString(),
          anneeFiscale: map["anneeFiscale"].toString(),
          codeNote: map["codeNote"].toString(),
          statut: int.parse(map["statut"].toString()),
          payementStatut: int.parse(map["payementStatut"].toString()),
          comment: map["comment"].toString(),
          nomCompletCb: map["nomCompletCb"].toString(),
          nomEts: map["nomEts"].toString(),
          dateTaxation: map["dateTaxation"].toString().toString(),
          idtypeCb: int.parse(map["idtypeCb"].toString()),
          typeCb: map["typeCb"].toString(),
          createdAt: map["createdAt"].toString(),
        ));
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  // recherche des utilisateurs
  Future<List<TaxationModel>> searchTaxations(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select taxations.idTaxation, taxations.idCompteBancaire,taxations.etatNoteSync,taxations.idCb, taxations.idUser,taxations.devise,taxations.anneeFiscale,taxations.codeNote, taxations.statut,taxations.payementStatut,taxations.comment,taxations.dateTaxation, taxations.createdAt, contibuables.nomCompletCb,contibuables.idtypeCb,contibuables.typeCb, contibuables.nomEts from taxations inner join contibuables on taxations.idCb=contibuables.id where taxations.codeNote like ? or contibuables.nomCompletCb like ? or contibuables.nomEts like ?",
        ["%$keyword%", "%$keyword%", "%$keyword%"]);
    return searchResult.map((e) => TaxationModel.fromMap(e)).toList();
  }

  //Delete user
  Future<int> deleteTaxation(int id) async {
    final Database db = await initDB();
    return db.delete('taxations', where: 'idTaxation = ?', whereArgs: [id]);
  }

  Future<int> createTaxation(TaxationModel user) async {
    final Database db = await initDB();
    return db.insert('taxations', user.toMap());
  }

  Future<int> insertTaxationData(Map<String, dynamic> svData) async {
    final Database db = await initDB();
    return await db.insert('taxations', svData);
  }

  Future<int> updateTaxationStatut(idTaxation) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update taxations set statut=?  where idTaxation = ?', [1, idTaxation]);
  }

  Future<int> updateTaxation(
      devise, anneeFiscale, comment, dateTaxation, idCb, idTaxation) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update taxations set devise=?, anneeFiscale=?, comment=?, dateTaxation=?, idCb=?  where idTaxation = ?',
        [devise, anneeFiscale, comment, dateTaxation, idCb, idTaxation]);
  }

  Future<int> updateInitStoreEtatTaxation() async {
    final Database db = await initDB();
    return db.rawUpdate('update taxations set etatNoteSync=0 ');
  }

  Future<int> updateTaxationEtat(etatNoteSync, idTaxation) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update taxations set etatNoteSync=?  where idTaxation = ?',
        [etatNoteSync, idTaxation]);
  }

  //pour la synchronisation
  Future saveToMysqlTaxation(List dataList) async {
    for (var i = 0; i < dataList.length; i++) {
      Map<String, dynamic> data = {
        "id": "",
        "codeCb": dataList[i]['codeCb'].toString(),
        "idTaxation": dataList[i]['idTaxation'].toString(),
        "idCompteBancaire": dataList[i]['idCompteBancaire'].toString(),
        "idCb": dataList[i]['idCb'].toString(),
        "idUser": dataList[i]['idUser'].toString(),
        "devise": dataList[i]['devise'].toString(),
        "anneeFiscale": dataList[i]['anneeFiscale'].toString(),
        "codeNote": dataList[i]['codeNote'].toString(),
        // "statut": dataList[i]['statut'].toString(),
        "statut": 7,
        "payementStatut": dataList[i]['payementStatut'].toString(),
        "comment": dataList[i]['comment'].toString(),
        "dateTaxation": dataList[i]['dateTaxation'].toString(),
      };

      // print('Taxation : $data');
      insertQueryBDonLineTaxation(data, dataList[i]['idTaxation']);
    }
  }

  Future insertQueryBDonLineTaxation(Map svData, int id) async {
    try {
      final String dataState;
      final res = await http.post(
          Uri.parse("${CallApi.ApiUrl.toString()}insert_taxation_mobile_app"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(svData));

      if (res.statusCode == 200) {
        dataState = jsonDecode(res.body)['dataState'].toString();
        var message = jsonDecode(res.body)['data'].toString();

        print("message: $message");
        if (dataState == "1") {
          //changement d'etat de cb envoyé au serveur
          // updateTaxationEtat(1, id);

          updateTaxationEtat(1, id).whenComplete(() async {
            List detailTaxationList =
                await fetchDataListDetailTaxationSendToOnlineAppByIdTaxation(
                    id);
            saveToMysqlDetailTaxation(detailTaxationList);
          });

          // updateTaxationEtat(1, id).whenComplete(() {
          //   saveToMysqlDetailTaxation(detailTaxationList);
          // });

          CallApi.showMsg(message);
        }
      } else {
        dataState = "0";
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }
  }

  /*
  *
  *=========================
  * Fin Taxation
  *=========================
  */

  /*
  *
  *=========================
  * DETAIL Taxation
  *=========================
  */

  //show categorie list
  Future fetchDataListDetailTaxation(int idTaxation) async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from detail_taxations where idTaxation=$idTaxation order by id desc');
      for (var map in maps) {
        userList.add(map);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future fetchDataListDetailTaxationSendToOnlineApp() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select taxations.etatNoteSync, taxations.statut, detail_taxations.id, detail_taxations.idTaxation,detail_taxations.idCatTaxe,detail_taxations.idUser, detail_taxations.groupeCat,detail_taxations.periode,detail_taxations.date_periode_debit,detail_taxations.date_periode_fin,detail_taxations.pu,detail_taxations.qte,detail_taxations.montant_reel,detail_taxations.commentaire,detail_taxations.numero_maison,detail_taxations.locataire,detail_taxations.dateContrat_debit,detail_taxations.dateContrat_fin, detail_taxations.nbr_mois,detail_taxations.num_chassie,detail_taxations.propriete_place,detail_taxations.passager,detail_taxations.codeNote,detail_taxations.createdAt,category_taxes.nomCatTaxe  from detail_taxations inner join category_taxes on detail_taxations.idCatTaxe=category_taxes.id inner join taxations on detail_taxations.idTaxation=taxations.idTaxation where taxations.statut=1 and taxations.etatNoteSync=1 order by detail_taxations.id desc');
      for (var map in maps) {
        userList.add(map);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future fetchDataListDetailTaxationSendToOnlineAppByIdTaxation(
      int idTaxation) async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select taxations.etatNoteSync, taxations.statut, detail_taxations.id, detail_taxations.idTaxation,detail_taxations.idCatTaxe,detail_taxations.idUser, detail_taxations.groupeCat,detail_taxations.periode,detail_taxations.date_periode_debit,detail_taxations.date_periode_fin,detail_taxations.pu,detail_taxations.qte,detail_taxations.montant_reel,detail_taxations.commentaire,detail_taxations.numero_maison,detail_taxations.locataire,detail_taxations.dateContrat_debit,detail_taxations.dateContrat_fin, detail_taxations.nbr_mois,detail_taxations.num_chassie,detail_taxations.propriete_place,detail_taxations.passager,detail_taxations.codeNote,detail_taxations.createdAt,category_taxes.nomCatTaxe  from detail_taxations inner join category_taxes on detail_taxations.idCatTaxe=category_taxes.id inner join taxations on detail_taxations.idTaxation=taxations.idTaxation where taxations.statut=1 and taxations.etatNoteSync=1 and taxations.idTaxation=${idTaxation.toString()} order by detail_taxations.id desc');
      for (var map in maps) {
        userList.add(map);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  //Get DetailTaxationModel
  Future<List<DetailTaxationModel>> fetchDetailTaxation(idTaxation) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery(
        'select detail_taxations.id, detail_taxations.idTaxation,detail_taxations.idCatTaxe,detail_taxations.idUser, detail_taxations.groupeCat,detail_taxations.periode,detail_taxations.date_periode_debit,detail_taxations.date_periode_fin,detail_taxations.pu,detail_taxations.qte,detail_taxations.montant_reel,detail_taxations.commentaire,detail_taxations.numero_maison,detail_taxations.locataire,detail_taxations.dateContrat_debit,detail_taxations.dateContrat_fin, detail_taxations.nbr_mois,detail_taxations.num_chassie,detail_taxations.propriete_place,detail_taxations.passager,detail_taxations.codeNote,detail_taxations.createdAt,category_taxes.nomCatTaxe  from detail_taxations inner join category_taxes on detail_taxations.idCatTaxe=category_taxes.id where detail_taxations.idTaxation=? order by detail_taxations.id desc',
        [idTaxation]);

    return result.map((e) => DetailTaxationModel.fromMap(e)).toList();
  }

  // recherche DetailTaxationModel
  Future<List<DetailTaxationModel>> searchDetailTaxations(
      String keyword, idTaxation) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select detail_taxations.id, detail_taxations.idTaxation,detail_taxations.idCatTaxe,detail_taxations.idUser, detail_taxations.groupeCat,detail_taxations.periode,detail_taxations.date_periode_debit,detail_taxations.date_periode_fin,detail_taxations.pu,detail_taxations.qte,detail_taxations.montant_reel,detail_taxations.commentaire,detail_taxations.numero_maison,detail_taxations.locataire,detail_taxations.dateContrat_debit,detail_taxations.dateContrat_fin, detail_taxations.nbr_mois,detail_taxations.num_chassie,detail_taxations.propriete_place,detail_taxations.passager,detail_taxations.codeNote,detail_taxations.createdAt,category_taxes.nomCatTaxe  from detail_taxations inner join category_taxes on detail_taxations.idCatTaxe=category_taxes.id where category_taxes.nomCatTaxe like? or detail_taxations.codeNote like? and detail_taxations.idTaxation=? ",
        ["%$keyword%", "%$keyword%", idTaxation]);
    return searchResult.map((e) => DetailTaxationModel.fromMap(e)).toList();
  }

  //Delete DetailTaxationModel
  Future<int> deleteDetailTaxation(int id) async {
    final Database db = await initDB();
    return db.delete('detail_taxations', where: 'id = ?', whereArgs: [id]);
  }

  //insert DetailTaxationModel
  Future<int> insertDetailTaxationData(Map<String, dynamic> svData) async {
    final Database db = await initDB();
    return await db.insert('detail_taxations', svData);
  }

  Future<int> updateDetailTaxation(idCatTaxe, qte, pu, montant_reel, id) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update detail_taxations set idCatTaxe=?, qte=?, pu=?, montant_reel=? where id = ?',
        [idCatTaxe, qte, pu, montant_reel, id]);
  }

  //synchronisation detail taxation
  //pour la synchronisation
  Future saveToMysqlDetailTaxation(List dataList) async {
    for (var i = 0; i < dataList.length; i++) {
      Map<String, dynamic> data = {
        "id": dataList[i]['id'].toString(),
        "etatNoteSync": dataList[i]['etatNoteSync'].toString(),
        "statut": dataList[i]['statut'].toString(),
        "idTaxation": dataList[i]['idTaxation'].toString(),
        "idCatTaxe": dataList[i]['idCatTaxe'].toString(),
        "idUser": dataList[i]['idUser'].toString(),
        "groupeCat": dataList[i]['groupeCat'].toString(),
        "periode": dataList[i]['periode'].toString(),
        "date_periode_debit": dataList[i]['date_periode_debit'].toString(),
        "date_periode_fin": dataList[i]['date_periode_fin'].toString(),
        "qte": dataList[i]['qte'].toString(),
        "pu": dataList[i]['pu'].toString(),
        "montant_reel": dataList[i]['montant_reel'].toString(),
        "commentaire": dataList[i]['commentaire'].toString(),
        "numero_maison": dataList[i]['numero_maison'].toString(),
        "locataire": dataList[i]['locataire'].toString(),
        "dateContrat_debit": dataList[i]['dateContrat_debit'].toString(),
        "dateContrat_fin": dataList[i]['dateContrat_fin'].toString(),
        "nbr_mois": dataList[i]['nbr_mois'].toString(),
        "num_chassie": dataList[i]['num_chassie'].toString(),
        "propriete_place": dataList[i]['propriete_place'].toString(),
        "passager": dataList[i]['passager'].toString(),
        "codeNote": dataList[i]['codeNote'].toString(),
        "createdAt": dataList[i]['createdAt'].toString(),
        "nomCatTaxe": dataList[i]['nomCatTaxe'].toString(),
      };

      // print('Detail Taxation : $data');
      insertQueryBDonLineDetailTaxation(data);
    }
  }

  Future insertQueryBDonLineDetailTaxation(Map svData) async {
    try {
      final String dataState;
      final res = await http.post(
          Uri.parse(
              "${CallApi.ApiUrl.toString()}insert_detail_taxation_mobile_app"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(svData));

      if (res.statusCode == 200) {
        dataState = jsonDecode(res.body)['dataState'].toString();
        var message = jsonDecode(res.body)['data'].toString();

        print("message: $message");
        if (dataState == "1") {
          CallApi.showMsg(message);
        }
      } else {
        dataState = "0";
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }
  }

  /*
  *
  *=========================
  * Fin Taxation
  *=========================
  */

  /*
  *
  *=========================
  * Immatriculation
  *=========================
  */
  //CRUD Methods immatriculation
  //Search Method
  Future<List<ImmatriculationModel>> searchImmatriculations(
      String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from immatriculation where nomSousLibelle LIKE ?",
        ["%$keyword%"]);
    return searchResult.map((e) => ImmatriculationModel.fromMap(e)).toList();
  }

  //Create Immatriculation
  Future<int> createImmatriculation(ImmatriculationModel note) async {
    final Database db = await initDB();
    return db.insert('immatriculation', note.toMap());
  }

  //Get Immatriculation
  Future<List<ImmatriculationModel>> getImmatriculations() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db
        .rawQuery('select * from immatriculation order by idLibelle desc');
    return result.map((e) => ImmatriculationModel.fromMap(e)).toList();
  }

  //Delete Immatriculation
  Future<int> deleteImmatriculation(int id) async {
    final Database db = await initDB();
    return db.delete('immatriculation',
        where: 'idImmatriculation = ?', whereArgs: [id]);
  }

  //Update Immatriculation
  Future<int> updateImmatriculation(
      idSousLibelle, nomSousLibelle, idImmatriculation) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update immatriculation set idSousLibelle = ?, nomSousLibelle = ? where idImmatriculation = ?',
        [idSousLibelle, nomSousLibelle, idImmatriculation]);
  }

  //show categorie list
  Future fetchDataListImmatriculation() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from immatriculation order by idSousLibelle desc limit 10000');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  Future getImmatriculationExist(int id) async {
    final Database db = await initDB();
    var result = await db
        .rawQuery("select * from immatriculation where idSousLibelle= $id ");
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //get Taxe on line app
  Future getImmatriculationOnLineApp() async {
    final Database dbClient = await initDB();

    //liste des utilisateur on line
    List dataOnLineAppList = [];

    try {
      //requete
      final response = await http
          .get(Uri.parse('${CallApi.ApiUrl}getSousLibelleTugGroupe/5'));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'];

        dataOnLineAppList = data;

        await dbClient.delete('immatriculation');

        //boucle
        for (var i = 0; i < dataOnLineAppList.length; i++) {
          Map<String, dynamic> svData = {
            "idSousLibelle": int.parse(dataOnLineAppList[i]['id'].toString()),
            "idLibelle":
                int.parse(dataOnLineAppList[i]['idLibelle'].toString()),
            "nomSousLibelle": dataOnLineAppList[i]['nomSousLibelle'].toString(),
            "createdAt": dataOnLineAppList[i]['created_at'].toString(),
          };

          // print(svData);

          await dbClient.insert('immatriculation', svData);
        }

        // print(data);
      } else {
        print('Error retrieving data: ${response.body}');
      }
    } catch (e) {
      CallApi.showErrorMsg(e.toString());
      print(e.toString());
    }
  }

  /*
  *
  *=======================
  * Table immatriculation
  *=======================
  */

  /*
  *
  *=========================
  * PeageRoute
  *=========================
  */
  //CRUD Methods peage
  //Search Method
  Future<List<PeageModel>> searchPeages(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from peage where nomCb LIKE ? or nomCatTaxe like ? or codeNote like ?",
        ["%$keyword%", "%$keyword%", "%$keyword%"]);
    return searchResult.map((e) => PeageModel.fromMap(e)).toList();
  }

  //Create peage
  Future<int> createPeage(PeageModel note) async {
    final Database db = await initDB();
    return db.insert('peage', note.toMap());
  }

  //insert json Peage
  Future<int> insertPeageData(Map<String, dynamic> svData) async {
    final Database db = await initDB();
    return await db.insert('peage', svData);
  }

  //Get peage
  Future<List<PeageModel>> getPeages() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result =
        await db.rawQuery('select * from peage order by idPeage desc');
    return result.map((e) => PeageModel.fromMap(e)).toList();
  }

  //Delete peage
  Future<int> deletePeage(int id) async {
    final Database db = await initDB();
    return db.delete('peage', where: 'idPeage = ?', whereArgs: [id]);
  }

  //Update idPeage
  Future<int> updateStatutPeage(int idPeage) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update peage set statutPeage = 1 where idPeage = ?', [idPeage]);
  }

  //Get PeageModel
  Future<List<PeageModel>> fetchDetailPeageByCodeNote(codeNote) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db
        .rawQuery('select * from peage where codeNote=? limit 1', [codeNote]);

    return result.map((e) => PeageModel.fromMap(e)).toList();
  }

  // statistique peage route
  Future<List<BarChartModel>> getStatistiquePeageRoute(String column) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery(
        "select SUM(montantUsd) as financial,datePaiement as typeCb, datePaiement as year from peage WHERE datePaiement > DATETIME('now', '-30 day') group by datePaiement");
    return result.map((e) => BarChartModel.fromMap(e)).toList();
  }

  Future getListStatistiquePeageRoute(String column) async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.rawQuery(
        "select SUM(montantUsd) as financial,datePaiement as typeCb, datePaiement as year from peage WHERE datePaiement > DATETIME('now', '-30 day') group by datePaiement ORDER BY idPeage desc");
    List datas = [];

    for (var item in result) {
      datas.add(item);
    }
    return datas;
  }

  //show Peage list
  Future fetchDataListPeage() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps =
          await dbClient.rawQuery('select * from peage order by idPeage asc');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  //show Peage list
  Future fetchDataListPeageOffLine() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from peage where statutPeage=0 order by idPeage asc');
      for (var item in maps) {
        userList.add(item);
      }
    } catch (e) {
      print(e.toString());
    }
    return userList;
  }

  /*
  *
  *==================================
  * synchronisation de Peage route
  *==================================
  *
  */

  //pour la synchronisation
  Future saveToMysqlPeageRoute(List dataList) async {
    for (var i = 0; i < dataList.length; i++) {
      Map<String, dynamic> data = {
        "id": "",
        "idCatTaxe": dataList[i]['idCatTaxe'].toString(),
        "idUser": dataList[i]['idUser'].toString(),
        "qte": dataList[i]['qte'].toString(),
        "pu": dataList[i]['pu'].toString(),
        "montantUsd": dataList[i]['montantUsd'].toString(),
        "nomAgent": dataList[i]['nomAgent'].toString(),
        "nomCb": dataList[i]['nomCb'].toString(),
        "telCb": dataList[i]['telCb'].toString(),
        "marqueVehicule": dataList[i]['marqueVehicule'].toString(),
        "modelVehicule": dataList[i]['modelVehicule'].toString(),
        "chassieVehicule": dataList[i]['chassieVehicule'].toString(),
        "numPlaque": dataList[i]['numPlaque'].toString(),
        "devise": dataList[i]['devise'].toString(),
        "datePaiement": dataList[i]['datePaiement'].toString(),
        "codeNote": dataList[i]['codeNote'].toString(),
        "comment": dataList[i]['comment'].toString(),
        "nomCatTaxe": dataList[i]['nomCatTaxe'].toString(),
      };
      // print(data);
      insertQueryBDonLinePeageRoute(data, dataList[i]['idPeage']);
    }
  }

  Future insertQueryBDonLinePeageRoute(Map svData, int idPeage) async {
    try {
      final String dataState;
      final res = await http.post(
          Uri.parse("${CallApi.ApiUrl.toString()}store_mobile_paiege_route"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(svData));

      if (res.statusCode == 200) {
        dataState = jsonDecode(res.body)['dataState'].toString();
        var message = jsonDecode(res.body)['data'].toString();
        if (dataState == "1") {
          //changement d'etat de cb envoyé au serveur
          updateStatutPeage(int.parse(idPeage.toString()));

          CallApi.showMsg(message);
        }
      } else {
        dataState = "0";

        print(res.statusCode.toString());
      }
    } catch (e) {
      print(e.toString());
      CallApi.showErrorMsg(e.toString());
    }
  }
}
