import 'dart:ui';

import 'package:flutter/material.dart';

import 'canvas_element.dart';

class CanvasSnapshot {
  final List<CanvasElement> elements;
  final Color backgroundColor;
  final Size canvasSize;
  final String? selectedElementId;

  const CanvasSnapshot({
    required this.elements,
    required this.backgroundColor,
    required this.canvasSize,
    required this.selectedElementId,
  });

  factory CanvasSnapshot.fromState({
    required List<CanvasElement> elements,
    required Color backgroundColor,
    required Size canvasSize,
    required String? selectedElementId,
  }) {
    return CanvasSnapshot(
      elements: List<CanvasElement>.from(elements),
      backgroundColor: backgroundColor,
      canvasSize: canvasSize,
      selectedElementId: selectedElementId,
    );
  }
}
