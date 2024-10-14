import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrcodeGenerateImage extends StatelessWidget {
  const QrcodeGenerateImage({required this.text, required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: text,
      version: QrVersions.auto,
      size: size,
    );
  }
}
