import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/contribuable_model.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class DbHelper {
  final databaseName = "demo.db";

  //initialisation
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    final exists = await databaseExists(path);

    if (exists) {
      print('la base des données existe');
    } else {
      print("Aucune bd n'a été trouvée!!!");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join('assets', databaseName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      print('database coped!!!');
    }

    return await openDatabase(path);
  }

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

  //crud Contribuable
  //CRUD Methods
  //Search Method
  Future<List<ContribuableModel>> searchCb(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        "select * from contibuables where nomCompletCb LIKE ?", ["%$keyword%"]);
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
  Future<int> updateCb(typeCb, idtypeCb, nomCompletCb, telCb, telsmsCb, sexeCb,
      imageCb, nomEts, respoEts, idAvenue, numeroMaisonCb, id) async {
    final Database db = await initDB();

    return db.rawUpdate(
        "update contibuables set typeCb=?, idtypeCb=?, nomCompletCb=?, telCb=?,telsmsCb=?, sexeCb=?, imageCb=?, nomEts=?, respoEts=?, respoEts=?, idAvenue=?, numeroMaisonCb=? idwhere id = ?",
        [
          typeCb,
          idtypeCb,
          nomCompletCb,
          telCb,
          telsmsCb,
          sexeCb,
          imageCb,
          nomEts,
          respoEts,
          idAvenue,
          numeroMaisonCb,
          id
        ]);
  }

  //Update Notes
  Future<int> updateEtatCb(etatCb, id) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update contibuables set etatCb = ? where id = ?', [etatCb, id]);
  }

  Future fetchDataList() async {
    final Database dbClient = await initDB();
    List userList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'select * from contibuables where etatCb=? order by id desc limit 200',
          [0]);
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

  /*
  *
  *================================
  * La synchronisation
  *================================
  *
  */
  //tester la connexion internet
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
}
