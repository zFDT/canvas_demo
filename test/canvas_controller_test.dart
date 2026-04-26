import 'dart:typed_data';

import 'package:canvas_demo/controllers/canvas_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  test('can add image/text and undo redo', () {
    final controller = CanvasController();

    controller.addImageElement(Uint8List.fromList([1, 2, 3]));
    controller.addTextElement(content: 'Hello');

    expect(controller.elements.length, 2);

    controller.undo();
    expect(controller.elements.length, 1);

    controller.redo();
    expect(controller.elements.length, 2);
  });

  test('updates text content with history', () {
    final controller = CanvasController();
    controller.addTextElement(content: 'Old');

    final id = controller.elements.first.id;
    controller.updateTextElement(id,
        content: 'New', fontSize: 48, textColor: Colors.red);

    expect(controller.elements.first.content, 'New');
    expect(controller.elements.first.fontSize, 48);

    controller.undo();
    expect(controller.elements.first.content, 'Old');
  });

  test('background and canvas size support undo', () {
    final controller = CanvasController();

    controller.setBackgroundColor(Colors.black);
    controller.setCanvasSize(const Size(720, 1280));

    expect(controller.backgroundColor.value, Colors.black);
    expect(controller.canvasSize.value, const Size(720, 1280));

    controller.undo();
    expect(controller.canvasSize.value, const Size(375, 812));

    controller.undo();
    expect(controller.backgroundColor.value, Colors.white);
  });

  test('clear canvas is undoable and keeps canvas settings', () {
    final controller = CanvasController();

    controller.setBackgroundColor(Colors.black);
    controller.setCanvasSize(const Size(900, 600));
    controller.addTextElement(content: 'A');
    controller.addImageElement(Uint8List.fromList([1, 2, 3]));

    expect(controller.elements.length, 2);

    controller.clearCanvas();

    expect(controller.elements, isEmpty);
    expect(controller.backgroundColor.value, Colors.black);
    expect(controller.canvasSize.value, const Size(900, 600));

    controller.undo();

    expect(controller.elements.length, 2);
    expect(controller.backgroundColor.value, Colors.black);
    expect(controller.canvasSize.value, const Size(900, 600));
  });
}
