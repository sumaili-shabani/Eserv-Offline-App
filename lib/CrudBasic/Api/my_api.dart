import 'dart:convert';

// import 'package:flutter/cupertino.dart';
import 'package:demoapp/CrudBasic/Model/article_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallApi {
  final String _url = 'http://192.168.82.127:8000/api/';
  final String _imgUrl = 'http://192.168.82.127:8000/uploads/';
  static String ApiUrl = "http://192.168.82.127:8000/api/";
  getImage() {
    return _imgUrl;
  }

  getFormatedDate(mydate) {
    var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    var inputDate = inputFormat.parse(mydate);
    var outputFormat = DateFormat('dd/MM/yyyy');
    return outputFormat.format(inputDate);
  }

  postData(data, apiUrl) async {
    // var fullUrl = _url + apiUrl + await _getToken();
    var fullUrl = _url + apiUrl;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(apiUrl) async {
    // var fullUrl = _url + apiUrl + await _getToken();
    var fullUrl = _url + apiUrl;
    return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    return '?token=$token';
  }

  // getArticles(apiUrl) async {}
  // getPublicData(apiUrl) async {}

  /*
  *
  * =======================
  * Mes scripts commance
  * =======================
  *
  */

  static showMsg(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM, // Position at bottom
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  static showErrorMsg(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM, // Position at bottom
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static insertOrUpdateData(url, Map pdata) async {
    try {
      final res =
          await http.post(Uri.parse("${ApiUrl.toString()}${url.toString()}"),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(pdata));

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body)['data'];
        showMsg(data.toString());
      } else {
        showErrorMsg("Erreur de modification des données!!!");
        return res;
      }
    } catch (e) {
      showErrorMsg(e.toString());
    }
  }

  static deleteData(url, int id) async {
    try {
      final res = await http.get(
        Uri.parse("${ApiUrl.toString()}${url.toString()}/${id.toInt()}"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body)['data'];
        showMsg(data.toString());
      } else {
        showErrorMsg("Erreur de supprimer les données!!!");
      }
    } catch (e) {
      showErrorMsg(e.toString());
    }
  }

  static postArticle(Map pdata) async {
    try {
      final res = await http.post(Uri.parse("${ApiUrl}insert_article"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: pdata);

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body)['data'];
        showMsg(data.toString());
        // print(data);
      } else {
        showErrorMsg("Erreur de charger les données!!!");
      }
    } catch (e) {
      showErrorMsg(e.toString());
    }
  }

  static getArticle() async {
    List<Article> article = [];
    try {
      final res = await http.get(
        Uri.parse("${ApiUrl}fetch_article_mobile"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        data['data'].forEach((value) => {
              article.add(
                Article(
                  value['id'],
                  value['title'],
                  value['description'],
                  value['created_at'],
                ),
              )
            });
        return article;
      } else {
        return [];
      }
    } catch (e) {
      showErrorMsg(e.toString());
    }
  }
}
