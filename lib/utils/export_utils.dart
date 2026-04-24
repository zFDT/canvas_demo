import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class ExportUtils {
  static Future<String?> exportToPng(GlobalKey repaintBoundaryKey) async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final fileName = "canvas_${DateTime.now().millisecondsSinceEpoch}.png";
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      
      return file.path;
    } catch (e) {
      print("Export failed: $e");
      return null;
    }
  }
}
