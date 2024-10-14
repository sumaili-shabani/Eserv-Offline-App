import 'package:flutter/material.dart';

class DateTextFildComponent extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool passwordInvisible;
  final TextEditingController controller;
  final bool? validatorInput;
  final int? maxLines;
  final String labeltext;
  const DateTextFildComponent(
      {super.key,
      required this.labeltext,
      required this.hint,
      required this.icon,
      required this.controller,
      this.passwordInvisible = false,
      this.validatorInput = false,
      this.maxLines});

  @override
  State<DateTextFildComponent> createState() => _DateTextFildComponentState();
}

class _DateTextFildComponentState extends State<DateTextFildComponent> {
  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;

    return TextFormField(
      obscureText: widget.passwordInvisible,
      controller: widget.controller,
      maxLines: widget.maxLines ?? 1,
      decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          hintText: widget.hint,
          label: Text(widget.labeltext),
          prefixIcon: Icon(widget.icon)),
      onTap: () {
        SelectDate(context);
      },
      validator: (value) {
        if (widget.validatorInput == true) {
          if (value!.isEmpty) {
            return "Ce champs est requis";
          } else {
            return null;
          }
        } else {
          return null;
        }
      },
    );
  }

  Future<void> SelectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      initialDate: DateTime.now(),
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        widget.controller.text = picked.toString().split(" ")[0];
      });
    }
  }
}
