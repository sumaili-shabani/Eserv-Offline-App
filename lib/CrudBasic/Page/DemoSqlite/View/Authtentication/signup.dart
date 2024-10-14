import 'package:demoapp/CrudBasic/Api/my_api.dart';
import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
// import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/DbHelper.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/SQLite/database_helper.dart';

import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Authtentication/login.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Components/button.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/View/Components/textfield.dart';
import 'package:demoapp/CrudBasic/Page/DemoSqlite/jsonModel/users.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //Controllers
  final fullName = TextEditingController();
  final email = TextEditingController();
  final usrName = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final db = DatabaseHelper();

  final formKey = GlobalKey<FormState>();

  signUp() async {
    if (formKey.currentState!.validate()) {
      if (password.text == confirmPassword.text) {
        var res = await db.createUser(Users(
            fullName: fullName.text,
            email: email.text,
            usrName: usrName.text,
            password: password.text));
        if (res > 0) {
          if (!mounted) return;
          CallApi.showMsg("Création de compte avec succès!!!");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        }
      } else {
        CallApi.showErrorMsg(
            "Les deux mot de passe doivent etre identiques!!!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Créer un nouveau compte",
                      style: TextStyle(
                          color: ConfigurationApp.primaryColor,
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InputField(
                      hint: "Nom et prénom",
                      icon: Icons.person,
                      controller: fullName,
                      validatorInput: true),
                  InputField(
                      hint: "E-mail",
                      icon: Icons.email,
                      controller: email,
                      validatorInput: true),
                  InputField(
                      hint: "Username",
                      icon: Icons.account_circle,
                      controller: usrName,
                      validatorInput: true),
                  InputField(
                      hint: "Mot de passe",
                      icon: Icons.lock,
                      controller: password,
                      passwordInvisible: true,
                      validatorInput: true),
                  InputField(
                      hint: "Entrez à nouveau le mot de passe",
                      icon: Icons.lock,
                      controller: confirmPassword,
                      passwordInvisible: true,
                      validatorInput: true),
                  const SizedBox(height: 10),
                  Button(
                      label: "S'INSCRIRE",
                      press: () {
                        signUp();
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Vous avez déjà un compte ?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()));
                          },
                          child: const Text("SE CONNECTER"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
