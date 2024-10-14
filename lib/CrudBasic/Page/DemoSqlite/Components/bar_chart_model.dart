import 'package:charts_flutter/flutter.dart' as charts;

class BarChartModel {
  final String year;
  final String? typeCb;
  final int financial;
  final charts.Color? color;

  BarChartModel({
    required this.year,
    required this.financial,
    this.typeCb,
    this.color,
  });

  factory BarChartModel.fromMap(Map<String, dynamic> json) => BarChartModel(
        year: json["year"],
        typeCb: json["typeCb"],
        financial: json["financial"] ?? 0,
        color: json["color"],
      );

  Map<String, dynamic> toMap() => {
        "year": year,
        "typeCb": typeCb,
        "financial": financial,
        "color": color,
      };
}
