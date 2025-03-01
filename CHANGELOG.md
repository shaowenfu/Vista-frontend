# VISTA Frontend Changelog

## [0.1.0] - 2025-03-01
### Added
- Continuous Voice Listening
  - Implemented background voice monitoring with wake word detection
  - Added automatic voice activity detection with 2-second silence threshold
  - Integrated Porcupine wake word engine for "Hey Vista" detection
  - Created visual feedback system for different listening states
  - Added toggle switch for enabling/disabling continuous listening
  - Implemented HTTP audio upload to backend API

### Changed
- Audio Recording
  - Modified recording flow to support both manual and automatic modes
  - Added visual indicators for recording status
  - Improved audio processing pipeline

## [0.1.0] - 2025-02-28
### Completed
- Core Components
  - Built basic structure of CameraScreen component
  - Implemented camera permission handling logic
  - Added audio recording framework
  - Implemented scene analysis timer functionality
  - Integrated haptic feedback and voice modules

### Planned
- [ ] Fix flutter_sound import and method call issues
- [ ] Implement _sendAudioToBackend for audio file upload
- [ ] Add error handling mechanisms
- [ ] Implement additional analysis modes (OCR and object detection)
- [ ] Add user interaction feedback
- [ ] Conduct comprehensive testing and optimization

## [0.1.0] - 2025-02-27
### Added
- Core Modules
  - Camera controller provider
  - Voice module for speech recognition and TTS
  - Haptic module for tactile feedback
  - API client for backend communication

- Features
  - Scene analysis service
  - Camera screen with preview
  - Voice command recognition
  - Mode switching functionality

### Changed
- Main Application
  - Added ProviderScope
  - Updated app configurations
  - Implemented single-page architecture

## [0.0.1] - 2025-02-14 to 2025-02-19
### Project Setup
- Initial project creation
- Requirements analysis
- Feature design
- Architecture planning
- Technology stack selection
