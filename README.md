
# 项目简介 / Project Overview

本项目包含：

## 1. wiimadhiit（前端 Flutter 跨平台应用）
- 使用 Flutter 框架开发，支持 Android、iOS、Web、Windows、macOS 和 Linux 多平台。
- 主入口文件位于 `lib/main.dart`。
- 目录结构包含各平台的原生工程文件夹（如 android、ios、web、windows、macos、linux 等）。
- **前端采用 StatelessWidget + Provider 组合进行 UI 构建与响应式状态管理，符合大厂级 Flutter 工程最佳实践。Profile 页面（`lib/presentation/profile/profile_page.dart`）为典型实现案例，分层结构清晰，UI 只负责展示，状态和业务逻辑由 ViewModel/UseCase/Service 解耦管理，便于团队协作和长期演进。**


