import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:flutter/material.dart';

//We are going to design our own button

class ButtonComponent extends StatelessWidget {
  final String label;
  final VoidCallback press;
  final IconData? icon;
  const ButtonComponent(
      {super.key, required this.label, required this.press, this.icon});

  @override
  Widget build(BuildContext context) {
    //Query width and height of device for being fit or responsive
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width * 0.4,
      height: 55,
      decoration: BoxDecoration(
          color: ConfigurationApp.successColor,
          borderRadius: BorderRadius.circular(8)),
      child: TextButton.icon(
        icon: Icon(
          icon,
          color: ConfigurationApp.whiteColor,
        ),
        onPressed: press,
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
