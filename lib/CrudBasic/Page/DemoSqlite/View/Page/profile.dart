import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Authtentication/login.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Components/button.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final Users? profile;
  const Profile({super.key, this.profile});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 45.0, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: ConfigurationApp.primaryColor,
                radius: 77,
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/avatar.png"),
                  radius: 75,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.profile!.fullName ?? "",
                style: const TextStyle(
                    fontSize: 28, color: ConfigurationApp.primaryColor),
              ),
              Text(
                widget.profile!.email ?? "",
                style: const TextStyle(fontSize: 17, color: Colors.grey),
              ),
              Button(
                  label: "S'INSCRIRE",
                  press: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  }),
              ListTile(
                leading: const Icon(Icons.person, size: 30),
                subtitle: const Text("Nom et prénom"),
                title: Text(widget.profile!.fullName ?? ""),
              ),
              ListTile(
                leading: const Icon(Icons.email, size: 30),
                subtitle: const Text("E-mail"),
                title: Text(widget.profile!.email ?? ""),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle, size: 30),
                subtitle: Text(widget.profile!.usrName),
                title: const Text("admin"),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
