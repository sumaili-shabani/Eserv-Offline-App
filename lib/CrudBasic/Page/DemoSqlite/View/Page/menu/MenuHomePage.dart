import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Authtentication/login.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/menu/my_drawer_header.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Contribuable/Contribuable.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/DashboardPage.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/DashboardPeageRoute.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Journal/journalScreem.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/JournalPeageRoute.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Personnel/personnelScreem.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxation/taxationScreem.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxe/PeageRoute.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/pages/Taxe/SousLibelleScreem.dart';
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
    fetMenu();
  }

  int _currentIndex = 0;
  List<Widget> _screens = [];
  // final List<Widget> _screens = [
  //   const DashboardPeageRoute(),
  //   const JournalPeageRoute(),
  //   const PeageRoute(),
  // ];

  fetMenu() {
    List<Widget> screensTab = [];
    if (idRoleConnected != 9) {
      screensTab = [
        const DashboardPeageRoute(),
        const JournalPeageRoute(),
        const PeageRoute(),
      ];
      setState(() {
        _screens = screensTab;
      });
    } else {
      screensTab = [
        const PersonnelScreem(),
        const SousLibelleScreem(),
        const TaxeScreem(),
      ];

      setState(() {
        _screens = screensTab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_typing_uninitialized_variables
    var container;
    if (currentPage == DrawerSections.dashboard) {
      container = const DashboardPeageRoute();
    } else if (currentPage == DrawerSections.jouranl) {
      container = const JournalPeageRoute();
    } else if (currentPage == DrawerSections.contribuable) {
      container = const ContribuablePage();
    } else if (currentPage == DrawerSections.taxation) {
      container = const TaxationScreem();
    } else if (currentPage == DrawerSections.nomaclature) {
      container = const TaxeScreem();
    } else if (currentPage == DrawerSections.personnel) {
      container = const PersonnelScreem();
    } else if (currentPage == DrawerSections.immatriculation) {
      container = const SousLibelleScreem();
    } else if (currentPage == DrawerSections.peageRoute) {
      container = const PeageRoute();
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
      // body: container,
      body: idRoleConnected == 9 ? _screens[_currentIndex] : container,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 20,
        // backgroundColor: ConfigurationApp.successColor,
        fixedColor: ConfigurationApp.successColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: idRoleConnected == 9
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Tableau de bord',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card),
                  label: 'Synchronisation',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wallet_sharp),
                  label: 'Péage route',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Nomaclature',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.car_crash),
                  label: 'Immatriculation',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group_add),
                  label: 'Utilisateur',
                ),
              ],
      ),
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
                    menuItem(1, "Tableau de bord", Icons.dashboard_outlined,
                        currentPage == DrawerSections.dashboard ? true : false),
                    menuItem(2, "Synchronisation", Icons.credit_card,
                        currentPage == DrawerSections.jouranl ? true : false),
                    menuItem(
                        8,
                        "Péage Route",
                        Icons.wallet_sharp,
                        currentPage == DrawerSections.peageRoute
                            ? true
                            : false),
                  ],
                )
              // menu pour le super admin
              : Column(
                  children: [
                    menuItem(1, "Tableau de bord", Icons.dashboard_outlined,
                        currentPage == DrawerSections.dashboard ? true : false),
                    menuItem(2, "Synchronisation", Icons.credit_card,
                        currentPage == DrawerSections.jouranl ? true : false),

                    menuItem(
                        4,
                        "Nomaclature",
                        Icons.list,
                        currentPage == DrawerSections.nomaclature
                            ? true
                            : false),
                    // menuItem(
                    //     5,
                    //     "Contribuable",
                    //     Icons.person_pin_outlined,
                    //     currentPage == DrawerSections.contribuable ? true

                    //         : false),
                    // menuItem(3, "Taxation", Icons.payments_sharp,
                    //     currentPage == DrawerSections.taxation ? true : false),
                    menuItem(
                        7,
                        "immatriculation",
                        Icons.car_crash,
                        currentPage == DrawerSections.immatriculation
                            ? true
                            : false),
                    menuItem(6, "Compte utilisateur", Icons.group_add,
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
              setState(() {
                _currentIndex = 0;
              });
            } else if (id == 2) {
              currentPage = DrawerSections.jouranl;
              setState(() {
                _currentIndex = 1;
              });
            } else if (id == 8) {
              currentPage = DrawerSections.peageRoute;
              setState(() {
                _currentIndex = 2;
              });
            } else if (id == 3) {
              currentPage = DrawerSections.taxation;
            } else if (id == 4) {
              currentPage = DrawerSections.nomaclature;
            } else if (id == 5) {
              currentPage = DrawerSections.contribuable;
            } else if (id == 6) {
              currentPage = DrawerSections.personnel;
            } else if (id == 7) {
              currentPage = DrawerSections.immatriculation;
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
  immatriculation,
  peageRoute,
}
