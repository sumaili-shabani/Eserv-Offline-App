import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
// import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/DbHelper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Authtentication/signup.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Components/button.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Components/textfield.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Page/menu/MenuHomePage.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Our controllers
  //Controller is used to take the value from user and pass it to database
  final usrName = TextEditingController();
  final password = TextEditingController();

  bool isChecked = false;
  bool isLoginTrue = false;

  final db = DatabaseHelper();
  //Login Method
  //We will take the value of text fields using controllers in order to verify whether details are correct or not
  login() async {
    List userData = [];
    var res = await db
        .authenticate(Users(usrName: usrName.text, password: password.text));
    if (res == true) {
      //If result is correct then go to profile or home
      if (!mounted) return;

      userData = await db.authenticateConnected(
          Users(usrName: usrName.text, password: password.text));

      CallApi.showMsg("Bienvenu ${usrName.text}");

      // print(userData);

      for (var i = 0; i < userData.length; i++) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('connected', userData[i]['usrName']);
        localStorage.setInt('idConnected', userData[i]['id']);
        localStorage.setInt('idRoleConnected', userData[i]['idRole']);
        localStorage.setInt('refConnected', userData[i]['usrId']);
        localStorage.setString('fullNameConnected', userData[i]['fullName']);
        localStorage.setString('emailConnected', userData[i]['email']);
      }

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const MenuHomePage()));

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => Profile(profile: usrDetails))
      //         );
    } else {
      //Otherwise show the error message
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  registerCount() async {
    try {
      var res = await db.createUser(Users(
        fullName: "Roger Sumaili",
        email: "superadmin@e-serv.org",
        usrName: "superAdmin",
        password: "9Patrona@1234",
        id: 60,
        idRole: 12,
      ));
      if (res > 0) {
        if (!mounted) return;
        CallApi.showMsg("Création de compte avec succès!!!");
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } catch (e) {
      CallApi.showErrorMsg(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Because we don't have account, we must create one to authenticate
                //lets go to sign up

                Image.asset(
                  "assets/images/logodgrphu.png",
                  width: 210,
                ),
                const SizedBox(height: 15),
                InputField(
                    hint: "Nom utilisateur",
                    icon: Icons.account_circle,
                    controller: usrName,
                    validatorInput: true),
                InputField(
                    hint: "Mot de passe",
                    icon: Icons.lock,
                    controller: password,
                    passwordInvisible: true,
                    validatorInput: true),

                ListTile(
                  horizontalTitleGap: 2,
                  title: const Text("Souviens-toi de moi"),
                  leading: Checkbox(
                    activeColor: ConfigurationApp.primaryColor,
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = !isChecked;
                      });
                    },
                  ),
                ),

                //Our login button
                Button(
                    label: "SE CONNECTER",
                    press: () {
                      login();
                    }),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Vous n'avez pas de compte ?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                        onPressed: () {
                          registerCount();
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => const SignupScreen()));
                          CallApi.showMsg(
                              "La création de compte e-serv nécessite une approbation des administrateurs du système. prière de les contacter pour avoir accès au système svp!!!");
                        },
                        child: const Text("S'INSCRIRE"))
                  ],
                ),

                // Access denied message in case when your username and password is incorrect
                //By default we must hide it
                //When login is not true then display the message
                isLoginTrue
                    ? Text(
                        "Le nom d'utilisateur ou le mot de passe est incorrect",
                        style: TextStyle(color: Colors.red.shade900),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
