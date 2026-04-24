
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/canvas_element.dart';

class CanvasController extends GetxController {
  var elements = <CanvasElement>[].obs;
  var backgroundColor = Colors.white.obs;
  var canvasSize = const Size(1080, 1920).obs;

  final _undoStack = <List<CanvasElement>>[].obs;
  final _redoStack = <List<CanvasElement>>[].obs;

  void addElement(CanvasElement element) {
    _saveState();
    elements.add(element);
  }

  void selectElement(String? id) {
    for (int i = 0; i < elements.length; i++) {
      final el = elements[i];
      if (el.id == id) {
        if (!el.isSelected) {
          elements[i] = el.copyWith(isSelected: true);
        }
      } else {
        if (el.isSelected) {
          elements[i] = el.copyWith(isSelected: false);
        }
      }
    }
    elements.refresh();
  }

  void updateElement(String id, CanvasElement newElement) {
    final index = elements.indexWhere((e) => e.id == id);
    if (index != -1) {
      elements[index] = newElement;
      elements.refresh();
    }
  }

  void finishUpdate() {
    _saveState();
  }

  void removeElement(String id) {
    _saveState();
    elements.removeWhere((e) => e.id == id);
  }

  void setBackgroundColor(Color color) {
    backgroundColor.value = color;
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(List.from(elements));
    elements.value = _undoStack.removeLast();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _saveState(); // Save current state to undo before redoing
    elements.value = _redoStack.removeLast();
  }

  void _saveState() {
    _undoStack.add(List.from(elements));
    _redoStack.clear(); // Clear redo stack on new action
    if (_undoStack.length > 20) { // Limit history size
      _undoStack.removeAt(0);
    }
  }
}
