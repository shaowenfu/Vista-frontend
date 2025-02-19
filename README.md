# VISTA - Visual Assistance App

<div align="center">

[![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D3.2.3-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-%3E%3D3.2.3-blue.svg)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

[English](README.md) | [简体中文](README_zh.md)

VISTA is a Flutter-based visual assistance application designed to help visually impaired individuals better perceive and understand their surroundings.

</div>

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔍 Scene Understanding | Real-time analysis and description of surroundings |
| 📝 Text Recognition | Detect and read text content aloud |
| 🎯 Object Detection | Identify and locate objects in the environment |
| ♿ Accessibility | Complete voice feedback and haptic support |

## 🏗️ Project Structure

```plaintext
lib/
├── app/                    # Core app configuration
│   ├── app.dart           # App entry component
│   └── routes.dart        # Route configuration
├── core/                  # Core functionality modules
├── features/             # Feature modules
├── shared/              # Shared resources
└── data/                # Data layer
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: >=3.2.3 <4.0.0
- Dart SDK: >=3.2.3 <4.0.0
- Android Studio / VS Code
- Android SDK / Xcode (for deployment)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/vista_frontend.git
```

2. Install dependencies
```bash
cd vista_frontend
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| camera | Camera control |
| flutter_tts | Text-to-speech |
| speech_to_text | Speech recognition |
| vibration | Haptic feedback |
| provider | State management |

## 🎯 Accessibility Features

- Voice prompts for all buttons and controls
- System TalkBack/VoiceOver support
- Haptic feedback
- Large text and high contrast support

## 📝 Development Guidelines

- Follow Flutter official coding standards
- All UI components must be accessibility-compliant
- Error handling must include appropriate user feedback

## 🗺️ Roadmap

- [ ] Settings page
- [ ] User preferences storage
- [ ] Offline mode support
- [ ] Multi-language support
- [ ] Performance optimization

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) first.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📮 Contact

- Maintainer: Sherwen Fu
- Email:shaowenfu.pg@gmail.com

## 🙏 Acknowledgments

- Flutter Team
- Contributors
- Open source community
