//Our custom textfield

import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool passwordInvisible;
  final TextEditingController controller;
  final bool? validatorInput;
  const InputField(
      {super.key,
      required this.hint,
      required this.icon,
      required this.controller,
      this.passwordInvisible = false,
      this.validatorInput = false});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: size.width * .9,
      height: 55,
      decoration: BoxDecoration(
          color: ConfigurationApp.backgroundColor,
          borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: TextFormField(
          obscureText: passwordInvisible,
          controller: controller,
          decoration: InputDecoration(
              border: InputBorder.none, hintText: hint, icon: Icon(icon)),
          validator: (value) {
            if (value!.isEmpty) {
              return "Ce champs est requis";
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}
