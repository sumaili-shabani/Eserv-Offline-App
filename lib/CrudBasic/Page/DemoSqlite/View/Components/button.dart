import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:flutter/material.dart';

//We are going to design our own button

class Button extends StatelessWidget {
  final String label;
  final VoidCallback press;
  const Button({super.key, required this.label, required this.press});

  @override
  Widget build(BuildContext context) {
    //Query width and height of device for being fit or responsive
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: size.width * .9,
      height: 55,
      decoration: BoxDecoration(
          color: ConfigurationApp.successColor,
          borderRadius: BorderRadius.circular(8)),
      child: TextButton(
        onPressed: press,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
