import 'package:intl/intl.dart';

class Utils {
  static formatPrice(double price) => '\$ ${price.toStringAsFixed(1)}';
  static formatDate(DateTime date) => DateFormat("d/M/y").format(date);
}
