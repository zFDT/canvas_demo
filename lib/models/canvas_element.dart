import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ElementType { image, text }

class CanvasElement {
  final String id;
  final ElementType type;
  final Offset position;
  final double scale;
  final double rotation;

  // For Image
  final Uint8List? imageData;

  // For Text
  final String? content;
  final Color? textColor;
  final double? fontSize;
  final bool isSelected;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextAlign? textAlign;

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
    this.fontWeight,
    this.fontStyle,
    this.textAlign,
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
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextAlign? textAlign,
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
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}
