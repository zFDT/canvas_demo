import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/canvas_controller.dart';
import '../models/canvas_element.dart';

class CanvasView extends GetView<CanvasController> {
  const CanvasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画布合成'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: controller.undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: controller.redo),
          IconButton(icon: const Icon(Icons.save), onPressed: () {
            // Trigger export logic here
          }),
        ],
      ),
      body: GestureDetector(
        onTap: () => controller.selectElement(null),
        child: Obx(() => Container(
          color: controller.backgroundColor.value,
          width: controller.canvasSize.value.width,
          height: controller.canvasSize.value.height,
          child: Stack(
            children: controller.elements.map((element) {
              return _buildElement(element);
            }).toList(),
          ),
        )),
      ),
    );
  }

  Widget _buildElement(CanvasElement element) {
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () => controller.selectElement(element.id),
        onPanUpdate: (details) {
          final newPos = element.position + details.delta;
          controller.updateElement(element.id, element.copyWith(position: newPos));
        },
        onPanEnd: (_) => controller.finishUpdate(),
        onScaleUpdate: (details) {
          final newScale = (element.scale * details.scale).clamp(0.1, 5.0);
          controller.updateElement(element.id, element.copyWith(scale: newScale));
        },
        onScaleEnd: (_) => controller.finishUpdate(),
        child: Container(
          decoration: element.isSelected 
              ? BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2.0),
                )
              : null,
          child: Transform.scale(
            scale: element.scale,
            child: element.type == ElementType.image
                ? Image.memory(element.imageData!)
                : Text(
                    element.content!,
                    style: TextStyle(
                      color: element.textColor,
                      fontSize: element.fontSize,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
