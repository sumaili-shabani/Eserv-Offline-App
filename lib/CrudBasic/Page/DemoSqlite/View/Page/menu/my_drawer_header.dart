import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  String? connected;
  int? id;
  int? idRoleConnected;
  int? refConnected;
  String? fullNameConnected;
  String? emailConnected;

  getUserConnected() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    setState(() {
      connected = localStorage.getString('connected');
      id = localStorage.getInt('idConnected');
      idRoleConnected = localStorage.getInt('idRoleConnected');
      refConnected = localStorage.getInt('refConnected');
      fullNameConnected = localStorage.getString('fullNameConnected');
      emailConnected = localStorage.getString('emailConnected');
    });
  }

  @override
  void initState() {
    super.initState();
    getUserConnected();
    // print(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ConfigurationApp.successColor,
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/avatar.jpg'),
              ),
            ),
          ),
          Text(
            '$fullNameConnected',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            '$emailConnected',
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
