import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

class ExportUtils {
  static Future<Uint8List?> exportToPngBytes(
      GlobalKey repaintBoundaryKey) async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Export bytes failed: $e');
      return null;
    }
  }

  static Future<String?> exportToPng(GlobalKey repaintBoundaryKey) async {
    try {
      final pngBytes = await exportToPngBytes(repaintBoundaryKey);
      if (pngBytes == null) return null;

      final directory = await getApplicationDocumentsDirectory();
      final fileName = "canvas_${DateTime.now().millisecondsSinceEpoch}.png";
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      debugPrint('Export file failed: $e');
      return null;
    }
  }

  static Future<bool> saveToGallery(Uint8List bytes) async {
    try {
      final String name = 'canvas_${DateTime.now().millisecondsSinceEpoch}';
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: name,
      );

      if (result is Map) {
        final success = result['isSuccess'] ?? result['success'];
        return success == true;
      }
      return false;
    } catch (e) {
      debugPrint('Save gallery failed: $e');
      return false;
    }
  }
}
