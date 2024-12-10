// import 'package:demoapp/CrudBasic/Page/InitialPage.dart';

// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Authtentication/login.dart';
// import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/mainScreem.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/menu/MenuHomePage.dart';

// import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/contacts.dart';
// import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/notes.dart';
// import 'package:demoapp/CrudBasic/Page/Offline/PageOnLine/FetchArticle.dart';
//ofline data
// import 'package:demoapp/CrudBasic/Page/Offline/Pages/Screens/home.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // Set the system UI overlay style, which controls the appearance of the status bar and navigation bar.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
  // ..customAnimation = CustomAnimation();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthController();
  }
}

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  late DatabaseHelper handler;

  String connected = "";
  Future getConnected() async {
    DatabaseHelper dbClient = DatabaseHelper();
    final Database db = await dbClient.initDB();

    // dbClient.DropTableIfExistsThenReCreateDetailTaxation();

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('connected')!;
    });
  }

  @override
  void initState() {
    super.initState();

    getConnected();

    // initialisation de la base des données
    // debit

    // handler = DatabaseHelper();
    // handler.initDB();

    // fin
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFLite Flutter - UDM',
      debugShowCheckedModeBanner: false, // Title of the application
      builder: EasyLoading.init(),
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color theme
      ),
      home: connected == '' ? const LoginScreen() : const MenuHomePage(),
      // home: const ContactsPage(),
    );
  }
}
