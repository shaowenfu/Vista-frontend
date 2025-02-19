# VISTA - 视觉辅助应用

VISTA是一个基于Flutter开发的视觉辅助应用，旨在帮助视障人士更好地感知和理解周围环境。

## 功能特点

- **场景理解**：实时分析和描述周围环境
- **文字识别**：识别并朗读文本内容
- **物体检测**：检测和识别周围物体
- **无障碍设计**：完整的语音反馈和触觉反馈支持

## 项目结构

```plaintext
lib/
├── app/                    # 应用核心配置
│   ├── app.dart           # 应用入口组件
│   └── routes.dart        # 路由配置
├── core/                   # 核心功能模块
│   ├── camera/            # 相机控制
│   ├── voice/             # 语音交互
│   └── haptic/            # 触觉反馈
├── features/              # 功能模块
│   ├── home/             # 主页
│   ├── scene/            # 场景理解
│   ├── ocr/              # 文字识别
│   └── object/           # 物体检测
├── shared/               # 共享资源
│   ├── widgets/          # 共享组件
│   ├── utils/            # 工具函数
│   └── constants.dart    # 常量定义
└── data/                 # 数据层
    ├── api_client.dart   # API客户端
    └── local_storage.dart # 本地存储
```

## 开发环境要求

- Flutter SDK: >=3.2.3 <4.0.0
- Dart SDK: >=3.2.3 <4.0.0
- Android Studio / VS Code
- Android SDK / Xcode (用于部署)

## 安装步骤

1. 克隆项目
```bash
git clone https://github.com/yourusername/vista_frontend.git
```

2. 安装依赖
```bash
cd vista_frontend
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 主要依赖

- **camera**: 相机控制
- **flutter_tts**: 语音合成
- **speech_to_text**: 语音识别
- **vibration**: 触觉反馈
- **provider**: 状态管理
- **http**: 网络请求
- **shared_preferences**: 本地存储

## 开发规范

- 使用中文注释说明代码功能
- 遵循Flutter官方代码规范
- 所有UI组件必须支持无障碍访问
- 错误处理必须包含适当的用户反馈

## 无障碍支持

- 所有按钮和控件都提供语音提示
- 支持系统TalkBack/VoiceOver
- 提供触觉反馈
- 支持大字体和高对比度

## 待实现功能

- [ ] 设置页面
- [ ] 用户偏好保存
- [ ] 离线模式支持
- [ ] 多语言支持
- [ ] 性能优化

## 贡献指南

1. Fork项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 许可证

[MIT License](LICENSE)

## 联系方式

- 项目维护者：[Your Name]
- 邮箱：[your.email@example.com]
