import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/canvas_controller.dart';
import '../models/canvas_element.dart';
import '../utils/export_utils.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key});

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  final CanvasController controller = Get.find<CanvasController>();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final ImagePicker _imagePicker = ImagePicker();

  static const Color _pageBg = Color(0xFFF5F5F5);
  static const Color _primaryBlue = Color(0xFF00AEFF);
  static const Color _panelGray = Color(0xFFE7E8E8);
  static const Color _textDark = Color(0xFF393A3A);

  double _gestureStartScale = 1;
  late Offset _gestureStartPosition;
  late Offset _gestureStartFocalPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectElement(null),
                child: Container(
                  width: double.infinity,
                  color: _pageBg,
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                    child: Obx(
                      () => RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Container(
                          width: controller.canvasSize.value.width,
                          height: controller.canvasSize.value.height,
                          color: controller.backgroundColor.value,
                          child: Stack(
                            children:
                                controller.elements.map(_buildElement).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GetBuilder<CanvasController>(
              builder: (_) {
                final selected = controller.selectedElement;
                if (selected == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: FilledButton.tonalIcon(
                    onPressed: controller.removeSelectedElement,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('删除选中元素'),
                  ),
                );
              },
            ),
            _buildBottomTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            splashRadius: 18,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _showCanvasSizeDialog,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _panelGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, size: 16, color: Color(0xFF666666)),
                      SizedBox(width: 4),
                      Text(
                        '标准打印板',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            height: 32,
            child: ElevatedButton(
              onPressed: _exportCanvas,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                '打印',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GetBuilder<CanvasController>(
            builder: (_) => Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo, size: 20),
                  onPressed: controller.canUndo ? controller.undo : null,
                  tooltip: '上一步',
                ),
                IconButton(
                  icon: const Icon(Icons.redo, size: 20),
                  onPressed: controller.canRedo ? controller.redo : null,
                  tooltip: '下一步',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTabBar() {
    return SafeArea(
      top: false,
      child: Container(
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFF0F2F2)),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomAction(
              icon: Icons.file_upload_outlined,
              label: '上传',
              onTap: _pickImage,
            ),
            _BottomAction(
              icon: Icons.auto_awesome_outlined,
              label: '图像AI',
              onTap: _showBackgroundColorDialog,
            ),
            _BottomAction(
              icon: Icons.text_fields,
              label: '文字',
              onTap: _handleTextAction,
            ),
            _BottomAction(
              icon: Icons.collections_outlined,
              label: '素材',
              onTap: _pickImage,
            ),
            _BottomAction(
              icon: Icons.dashboard_customize_outlined,
              label: '模版',
              onTap: _showCanvasSizeDialog,
            ),
            _BottomAction(
              icon: Icons.ios_share_outlined,
              label: '导出',
              onTap: _exportCanvas,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTextAction() {
    final selected = controller.selectedElement;
    if (selected != null && selected.type == ElementType.text) {
      _showEditTextDialog(selected);
      return;
    }
    _showAddTextDialog();
  }

  Widget _buildElement(CanvasElement element) {
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () {
          controller.selectElement(element.id);
          if (element.type == ElementType.text) {
            _showEditTextDialog(element);
          }
        },
        onScaleStart: (details) {
          controller.selectElement(element.id);
          controller.startElementInteraction();
          _gestureStartScale = element.scale;
          _gestureStartPosition = element.position;
          _gestureStartFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          final newScale = (_gestureStartScale * details.scale).clamp(0.2, 6.0);
          final delta = details.focalPoint - _gestureStartFocalPoint;
          final newPos = _gestureStartPosition + delta;
          controller.updateElementTransform(
            element.id,
            position: newPos,
            scale: newScale,
          );
        },
        onScaleEnd: (_) => controller.endElementInteraction(),
        child: Container(
          decoration: element.isSelected
              ? BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2.0),
                )
              : null,
          child: Transform.scale(
            scale: element.scale,
            child: element.type == ElementType.image
                ? _buildImageElement(element)
                : Text(
                    element.content ?? '',
                    style: TextStyle(
                      color: element.textColor ?? Colors.black,
                      fontSize: element.fontSize ?? 28,
                      fontWeight: element.fontWeight,
                      fontStyle: element.fontStyle,
                    ),
                    textAlign: element.textAlign,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageElement(CanvasElement element) {
    final bytes = element.imageData;
    if (bytes == null || bytes.isEmpty) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 320),
      child: Image.memory(bytes, fit: BoxFit.contain),
    );
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final Uint8List bytes = await file.readAsBytes();
    controller.addImageElement(bytes);
  }

  Future<void> _showAddTextDialog() async {
    final textController = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增文字'),
          content: TextField(
            controller: textController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: '输入文字内容'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('添加')),
          ],
        );
      },
    );

    if (created == true && textController.text.trim().isNotEmpty) {
      controller.addTextElement(content: textController.text.trim());
    }
  }

  Future<void> _showEditTextDialog(CanvasElement element) async {
    if (element.type != ElementType.text) return;

    final textController = TextEditingController(text: element.content ?? '');
    final sizeController = TextEditingController(
        text: (element.fontSize ?? 28).toStringAsFixed(0));
    final textColors = <Color>[
      Colors.black,
      Colors.white,
      Colors.blue,
      Colors.red,
      Colors.green,
    ];
    var selectedColor = element.textColor ?? Colors.black;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('编辑文字'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: '文本内容'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sizeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: '字号'),
                    ),
                    const SizedBox(height: 10),
                    const Text('文字颜色'),
                    Wrap(
                      spacing: 8,
                      children: textColors
                          .map(
                            (c) => GestureDetector(
                              onTap: () => setState(() => selectedColor = c),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: c,
                                child: selectedColor == c
                                    ? const Icon(Icons.check,
                                        size: 14, color: Colors.white)
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('保存')),
              ],
            );
          },
        );
      },
    );

    if (shouldSave == true) {
      final size = double.tryParse(sizeController.text.trim()) ??
          (element.fontSize ?? 28);
      controller.updateTextElement(
        element.id,
        content: textController.text.trim(),
        textColor: selectedColor,
        fontSize: size.clamp(10, 180),
      );
    }
  }

  Future<void> _showBackgroundColorDialog() async {
    final colors = <Color>[
      Colors.white,
      Colors.black,
      Colors.grey.shade200,
      Colors.blue.shade50,
      Colors.pink.shade50,
      Colors.green.shade50,
    ];

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择背景色'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colors
                .map(
                  (c) => GestureDetector(
                    onTap: () => Navigator.pop(context, c),
                    child: CircleAvatar(radius: 16, backgroundColor: c),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (selectedColor != null) {
      controller.setBackgroundColor(selectedColor);
    }
  }

  Future<void> _showCanvasSizeDialog() async {
    final widthController = TextEditingController(
        text: controller.canvasSize.value.width.toStringAsFixed(0));
    final heightController = TextEditingController(
        text: controller.canvasSize.value.height.toStringAsFixed(0));

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置画布尺寸'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '宽度 (px)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '高度 (px)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('应用')),
          ],
        );
      },
    );

    if (updated == true) {
      final width = double.tryParse(widthController.text.trim());
      final height = double.tryParse(heightController.text.trim());
      if (width != null && height != null && width > 100 && height > 100) {
        controller.setCanvasSize(Size(width, height));
      } else {
        Get.snackbar('尺寸无效', '请输入大于 100 的宽高');
      }
    }
  }

  Future<void> _exportCanvas() async {
    final bytes = await ExportUtils.exportToPngBytes(_repaintBoundaryKey);
    if (bytes == null) {
      Get.snackbar('导出失败', '无法生成 PNG');
      return;
    }

    final saved = await ExportUtils.saveToGallery(bytes);
    if (saved) {
      Get.snackbar('导出成功', '已保存到相册/媒体库');
      return;
    }

    final filePath = await ExportUtils.exportToPng(_repaintBoundaryKey);
    if (filePath != null) {
      Get.snackbar('已导出到应用目录', filePath, duration: const Duration(seconds: 3));
    } else {
      Get.snackbar('导出失败', '保存图片失败，请检查权限');
    }
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF393A3A)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                height: 1.2,
                color: Color(0xFF393A3A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
