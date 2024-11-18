import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImagePreviewWidget extends StatelessWidget {
  final Uint8List imageBytes;

  const ImagePreviewWidget({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}
