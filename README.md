# canvas_demo

Flutter 画布构图 Demo：基于 GetX 的绘制编辑器，支持画布元素的增删、快照回放与导出。

## 功能

- 画布元素模型（`CanvasElement`）：矩形 / 文本等元素抽象
- 快照系统（`CanvasSnapshot`）：绘制状态记录与回放
- 导出工具（`export_utils`）：画布内容导出
- GetX 状态管理（`CanvasController`）

## 目录

```
lib/
├── controllers/canvas_controller.dart   # GetX 控制器
├── models/canvas_element.dart           # 元素模型
├── models/canvas_snapshot.dart          # 快照模型
├── utils/export_utils.dart              # 导出工具
└── views/canvas_view.dart               # 画布视图
```

## 运行

```bash
flutter pub get
flutter run
```
