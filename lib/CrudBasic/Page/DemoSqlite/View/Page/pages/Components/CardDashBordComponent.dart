import 'package:demoapp/CrudBasic/Config/ConfigurationApp.dart';
import 'package:flutter/material.dart';

class CardDashboradComponent extends StatelessWidget {
  final String? titre;
  final String? number;
  final IconData? icon;
  final Color? color;
  final Color? textcolor;
  final String signeIcon;
  const CardDashboradComponent(
      {super.key,
      required this.titre,
      required this.number,
      required this.icon,
      required this.color,
      required this.textcolor,
      required this.signeIcon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: CircleAvatar(
            radius: 27,
            backgroundColor: color,
            child: Icon(
              icon,
              size: 40,
              color: textcolor,
            ),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titre ?? "",
              maxLines: 2,
              style: TextStyle(
                  fontFamily: "Open Sans", color: textcolor, fontSize: 14),
            ),
            Text(
              '$number $signeIcon',
              maxLines: 2,
              style: TextStyle(
                  fontSize: 14, color: textcolor, fontFamily: "Open Sans"),
            )
          ],
        )
      ],
    );
  }
}
