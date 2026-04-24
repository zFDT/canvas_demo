import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/canvas_controller.dart';
import 'views/canvas_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Canvas Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CanvasView(),
      initialBinding: BindingsBuilder(() {
        Get.put(CanvasController());
      }),
    );
  }
}
