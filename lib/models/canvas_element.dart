import 'dart:ui';

import 'package:flutter/foundation.dart';

enum ElementType { image, text }

class CanvasElement {
  final String id;
  final ElementType type;
  Offset position;
  double scale;
  double rotation;

  // For Image
  final Uint8List? imageData;

  // For Text
  final String? content;
  final Color? textColor;
  final double? fontSize;
  bool isSelected;

  CanvasElement({
    required this.id,
    required this.type,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.imageData,
    this.content,
    this.textColor,
    this.fontSize,
    this.isSelected = false,
  });

  CanvasElement copyWith({
    String? id,
    ElementType? type,
    Offset? position,
    double? scale,
    double? rotation,
    Uint8List? imageData,
    String? content,
    Color? textColor,
    double? fontSize,
    bool? isSelected,
  }) {
    return CanvasElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      imageData: imageData ?? this.imageData,
      content: content ?? this.content,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
