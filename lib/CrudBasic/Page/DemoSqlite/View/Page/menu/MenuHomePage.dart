import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Authtentication/login.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/menu/my_drawer_header.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Contribuable/Contribuable.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/DashboardPage.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Journal/journalScreem.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Personnel/personnelScreem.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxation/taxationScreem.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxe/TaxeScreem.dart';

// import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/notes.dart';
// import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuHomePage extends StatefulWidget {
  const MenuHomePage({super.key});

  @override
  State<MenuHomePage> createState() => _MenuHomePageState();
}

class _MenuHomePageState extends State<MenuHomePage> {
  var currentPage = DrawerSections.dashboard;
  String connected = "";
  int id = 0;
  int idRoleConnected = 0;
  int refConnected = 0;
  String fullNameConnected = "";
  String emailConnected = "";

  final db = DatabaseHelper();

  Future getConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('connected')!;
      id = localStorage.getInt('idConnected')!;
      idRoleConnected = localStorage.getInt('idRoleConnected')!;
      refConnected = localStorage.getInt('refConnected')!;
      fullNameConnected = localStorage.getString('fullNameConnected')!;
      emailConnected = localStorage.getString('emailConnected')!;
    });

    print("connected $connected");
  }

  Future logOut(BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('connected');
    localStorage.remove('idConnected');
    localStorage.remove('idRoleConnected');
    localStorage.remove('refConnected');
    localStorage.remove('fullNameConnected');
    localStorage.remove('emailConnected');
    CallApi.showMsg("Deconnexion avec succès!!!");

    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getConnected();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_typing_uninitialized_variables
    var container;
    if (currentPage == DrawerSections.dashboard) {
      container = const DashboardPage();
    } else if (currentPage == DrawerSections.jouranl) {
      container = const JournalScreem();
    } else if (currentPage == DrawerSections.contribuable) {
      container = const ContribuablePage();
    } else if (currentPage == DrawerSections.taxation) {
      container = const TaxationScreem();
    } else if (currentPage == DrawerSections.nomaclature) {
      container = const TaxeScreem();
    } else if (currentPage == DrawerSections.personnel) {
      container = const PersonnelScreem();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConfigurationApp.whiteColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              logOut(context);
            },
            icon: const Icon(Icons.logout),
            color: ConfigurationApp.blackColor,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 15,
              foregroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
        ],
        title: connected == ''
            ? const Text('')
            : Text(connected,
                style:
                    const TextStyle(color: Colors.black, letterSpacing: 1.5)),
      ),
      body: container,
      drawer: Drawer(
        shadowColor: ConfigurationApp.whiteColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const MyHeaderDrawer(),
              myDrawerList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget myDrawerList() {
    return Container(
      padding: const EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        // shows the list of menu drawer
        children: [
          // menu pour le percepteur
          idRoleConnected == 9
              ? Column(
                  children: [
                    menuItem(1, "Dashboard", Icons.dashboard_outlined,
                        currentPage == DrawerSections.dashboard ? true : false),
                    menuItem(2, "Journal", Icons.event,
                        currentPage == DrawerSections.jouranl ? true : false),
                    menuItem(3, "Taxation", Icons.payments_sharp,
                        currentPage == DrawerSections.taxation ? true : false),
                    menuItem(
                        5,
                        "Contribuable",
                        Icons.person_pin_outlined,
                        currentPage == DrawerSections.contribuable
                            ? true
                            : false),
                  ],
                )
              // menu pour le super admin
              : Column(
                  children: [
                    menuItem(1, "Dashboard", Icons.dashboard_outlined,
                        currentPage == DrawerSections.dashboard ? true : false),
                    menuItem(2, "Journal", Icons.event,
                        currentPage == DrawerSections.jouranl ? true : false),
                    menuItem(3, "Taxation", Icons.payments_sharp,
                        currentPage == DrawerSections.taxation ? true : false),
                    menuItem(
                        4,
                        "Nomaclature",
                        Icons.list,
                        currentPage == DrawerSections.nomaclature
                            ? true
                            : false),
                    menuItem(
                        5,
                        "Contribuable",
                        Icons.person_pin_outlined,
                        currentPage == DrawerSections.contribuable
                            ? true
                            : false),
                    menuItem(6, "Personnel", Icons.group,
                        currentPage == DrawerSections.personnel ? true : false),
                  ],
                ),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      color: selected ? Colors.grey[300] : Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          setState(() {
            if (id == 1) {
              currentPage = DrawerSections.dashboard;
            } else if (id == 2) {
              currentPage = DrawerSections.jouranl;
            } else if (id == 3) {
              currentPage = DrawerSections.taxation;
            } else if (id == 4) {
              currentPage = DrawerSections.nomaclature;
            } else if (id == 5) {
              currentPage = DrawerSections.contribuable;
            } else if (id == 6) {
              currentPage = DrawerSections.personnel;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum DrawerSections {
  dashboard,
  jouranl,
  taxation,
  nomaclature,
  personnel,
  contribuable,
  paiement,
}
