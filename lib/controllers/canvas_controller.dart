import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

import '../models/canvas_element.dart';
import '../models/canvas_snapshot.dart';

class CanvasController extends GetxController {
  final RxList<CanvasElement> elements = <CanvasElement>[].obs;
  final Rx<Color> backgroundColor = Colors.white.obs;
  final Rx<Size> canvasSize = const Size(375, 812).obs;
  final RxnString selectedElementId = RxnString();

  final List<CanvasSnapshot> _undoStack = <CanvasSnapshot>[];
  final List<CanvasSnapshot> _redoStack = <CanvasSnapshot>[];
  final Uuid _uuid = const Uuid();

  static const int _maxHistory = 50;
  bool _isElementInteractionActive = false;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  CanvasElement? get selectedElement {
    final id = selectedElementId.value;
    if (id == null) return null;
    for (final e in elements) {
      if (e.id == id) return e;
    }
    return null;
  }

  void addImageElement(Uint8List imageData, {Offset? position}) {
    _pushUndoSnapshot();
    final element = CanvasElement(
      id: _uuid.v4(),
      type: ElementType.image,
      position: position ?? _defaultInsertOffset(),
      imageData: imageData,
      scale: 1,
    );
    elements.add(element);
    selectElement(element.id);
    update();
  }

  void addTextElement({
    required String content,
    Color textColor = Colors.black,
    double fontSize = 28,
    Offset? position,
  }) {
    _pushUndoSnapshot();
    final element = CanvasElement(
      id: _uuid.v4(),
      type: ElementType.text,
      position: position ?? _defaultInsertOffset(),
      content: content,
      textColor: textColor,
      fontSize: fontSize,
      textAlign: TextAlign.left,
      fontWeight: FontWeight.w500,
      scale: 1,
    );
    elements.add(element);
    selectElement(element.id);
    update();
  }

  void selectElement(String? id) {
    selectedElementId.value = id;
    for (var i = 0; i < elements.length; i++) {
      final el = elements[i];
      final shouldSelect = el.id == id;
      if (el.isSelected != shouldSelect) {
        elements[i] = el.copyWith(isSelected: shouldSelect);
      }
    }
    elements.refresh();
    update();
  }

  void removeSelectedElement() {
    final id = selectedElementId.value;
    if (id == null) return;
    _pushUndoSnapshot();
    elements.removeWhere((e) => e.id == id);
    selectedElementId.value = null;
    elements.refresh();
    update();
  }

  void updateElementTransform(
    String id, {
    Offset? position,
    double? scale,
  }) {
    final index = elements.indexWhere((e) => e.id == id);
    if (index < 0) return;

    final oldElement = elements[index];
    elements[index] = oldElement.copyWith(
      position: position ?? oldElement.position,
      scale: scale ?? oldElement.scale,
    );
    elements.refresh();
    update();
  }

  void updateTextElement(
    String id, {
    String? content,
    Color? textColor,
    double? fontSize,
  }) {
    final index =
        elements.indexWhere((e) => e.id == id && e.type == ElementType.text);
    if (index < 0) return;

    _pushUndoSnapshot();
    final oldElement = elements[index];
    elements[index] = oldElement.copyWith(
      content: content ?? oldElement.content,
      textColor: textColor ?? oldElement.textColor,
      fontSize: fontSize ?? oldElement.fontSize,
    );
    elements.refresh();
    update();
  }

  void startElementInteraction() {
    if (_isElementInteractionActive) return;
    _isElementInteractionActive = true;
    _pushUndoSnapshot();
  }

  void endElementInteraction() {
    _isElementInteractionActive = false;
  }

  void setBackgroundColor(Color color) {
    if (backgroundColor.value == color) return;
    _pushUndoSnapshot();
    backgroundColor.value = color;
    update();
  }

  void setCanvasSize(Size size) {
    if (canvasSize.value == size) return;
    _pushUndoSnapshot();
    canvasSize.value = size;
    update();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_createSnapshot());
    final snapshot = _undoStack.removeLast();
    _restoreSnapshot(snapshot);
    update();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_createSnapshot());
    final snapshot = _redoStack.removeLast();
    _restoreSnapshot(snapshot);
    update();
  }

  Offset _defaultInsertOffset() {
    final size = canvasSize.value;
    return Offset(size.width * 0.18, size.height * 0.22);
  }

  void _pushUndoSnapshot() {
    _undoStack.add(_createSnapshot());
    _redoStack.clear();
    if (_undoStack.length > _maxHistory) {
      _undoStack.removeAt(0);
    }
  }

  CanvasSnapshot _createSnapshot() {
    return CanvasSnapshot.fromState(
      elements: elements,
      backgroundColor: backgroundColor.value,
      canvasSize: canvasSize.value,
      selectedElementId: selectedElementId.value,
    );
  }

  void _restoreSnapshot(CanvasSnapshot snapshot) {
    elements.value = List<CanvasElement>.from(snapshot.elements);
    backgroundColor.value = snapshot.backgroundColor;
    canvasSize.value = snapshot.canvasSize;
    selectedElementId.value = snapshot.selectedElementId;
    selectElement(snapshot.selectedElementId);
  }
}
