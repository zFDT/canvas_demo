# canvas_demo — Flutter 画布构图 Demo

基于 GetX 的 Flutter 画布绘制编辑器，实现画布元素的元素化建模、快照回放与内容导出。

## 项目简介

本项目是一个 Flutter 画布构图 Demo，包名为 `com.zhanghongxin.canvas_demo`。它围绕「画布」这一核心场景，将绘制内容抽象为可管理的元素模型，并提供快照记录/回放与导出能力，配合 GetX 完成状态管理与 UI 联动，构建一个轻量但结构清晰的绘制编辑器示例。

## 核心功能 / 技术特性

- **元素模型（`CanvasElement`）**：将画布上的矩形、文本等对象抽象为统一的元素模型，支持增删与属性描述。
- **快照系统（`CanvasSnapshot`）**：记录绘制状态，支持状态快照的保存与回放，便于演示「撤销/重放」类交互。
- **导出工具（`export_utils`）**：将画布内容导出为可用格式，打通「编辑 → 产物」的闭环。
- **GetX 状态管理（`CanvasController`）**：使用 GetX 管理画布状态与视图刷新，代码简洁、响应式清晰。

## 技术特色与复盘

### Canvas 绘制抽象

把画布中的各类图形统一抽象为 `CanvasElement`，弱化了「针对单个图形硬编码绘制」的耦合，使元素的新增、删除、修改都走同一套模型，为快照与导出奠定了基础。

### 快照 / 回放机制

通过 `CanvasSnapshot` 对绘制状态进行记录，结合 GetX 响应式刷新实现状态回放。该机制是「历史记录」类功能的简化实现，体现了状态不可变快照与视图分离的思路。

### 个人贡献

- 设计并实现元素模型、快照模型与导出工具等核心模块；
- 基于 GetX 搭建控制器与视图的响应式联动；
- 完成项目目录组织与运行说明。

### 收获与规划

- 收获：加深了对 Flutter 画布绘制、GetX 状态管理以及「模型—快照—导出」分层设计的理解。
- 规划：后续可扩展更多元素类型、支持拖拽/缩放手势，并引入序列化持久化与更完整的撤销/重做栈。

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
