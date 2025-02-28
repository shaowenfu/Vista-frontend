# Flutter Real-time Speech Recognition SDK

*Last updated: 2024-12-12 22:28:22*

## Table of Contents
- [Development Environment](#development-environment)
- [Installation](#installation)
- [Integration Guide](#integration-guide)
- [API Reference](#api-reference)
  - [ASRControllerConfig](#asrcontrollerconfig)
  - [ASRController](#asrcontroller)
  - [ASRData](#asrdata)
  - [ASRDataType](#asrdatatype)
  - [ASRError](#asrerror)
- [Custom Data Source](#custom-data-source)

## Overview
The SDK encapsulates Android and iOS real-time speech recognition functionality as a plugin, providing Flutter-based real-time speech recognition capabilities. This document introduces the SDK installation method and examples.

## Development Environment
- Dart >= 2.18.4
- Flutter >= 3.3.8
- Android API Level >= 16
- iOS >= 9.0

## Installation
1. Download the SDK from the [Control Console](https://console.cloud.tencent.com/)
2. The `asr_plugin` directory in the SDK is the Flutter plugin
3. Demo examples can be found in the `example` directory within the plugin

## Integration Guide
> Note: This plugin only supports Android and iOS platforms and includes platform-specific libraries. Make sure your development environment includes Android Studio and Xcode to avoid compilation issues.

1. Copy the `asr_plugin` directory to your Flutter project
2. Add dependency in your project's `pubspec.yaml`:
```yaml
dependencies:
  asr_plugin:
    path: ../asr_plugin  # Adjust path according to your asr_plugin location
```
3. Import the dependency in your code:
```dart
import 'package:asr_plugin/asr_plugin.dart';
```

## API Reference

### ASRControllerConfig
Configuration parameters for generating ASRController.

#### Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| appID | int | Tencent Cloud appID |
| projectID | int | Tencent Cloud projectID |
| secretID | String | Tencent Cloud secretID |
| secretKey | String | Tencent Cloud secretKey |
| engine_model_type | String | Engine type, default "16k_zh" |
| filter_dirty | int | Filter profanity settings |
| filter_modal | int | Filter modal particle settings |
| filter_punc | int | Filter punctuation settings |
| convert_num_mode | int | Arabic number conversion mode |
| hotword_id | String | Hotword ID |
| customization_id | String | Custom model ID |
| vad_silence_time | int | Voice activity detection threshold |
| needvad | int | Voice segmentation |
| word_info | int | Word-level timestamp settings |
| reinforce_hotword | int | Hotword enhancement |
| is_compress | bool | Enable audio compression |
| silence_detect | bool | Enable silence detection |
| silence_detect_duration | int | Silence detection duration (ms) |
| is_save_audio_file | bool | Save audio file setting |
| audio_file_path | String | Audio file save path |

#### Methods
```dart
Future<ASRController> build() async  // Creates ASRController
```

#### Example
```dart
var _config = ASRControllerConfig();
_config.filter_dirty = 1;
_config.filter_modal = 0;
_config.filter_punc = 0;
var _controller = await _config.build();
```

### ASRController
Controls speech recognition process and retrieves results.

#### Methods
```dart
Stream<ASRData> recognize() async*  // Start recognition
Stream<ASRData> recognizeWithDataSource(Stream<Uint8List>? source) async*  // Recognition with custom data source
stop() async  // Stop recognition
release() async  // Release resources
```

#### Example
```dart
try {
  if (_controller != null) {
    await _controller?.release();
  }
  _controller = await _config.build();
  
  await for (final val in _controller!.recognize()) {
    switch (val.type) {
      case ASRDataType.SLICE:
      case ASRDataType.SEGMENT:
        // Handle partial results
        break;
      case ASRDataType.SUCCESS:
        // Handle final results
        break;
    }
  }
} on ASRError catch (e) {
  // Handle errors
}
```

### ASRData
Data returned during recognition process.

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| type | ASRDataType | Data type |
| id | int? | Sentence ID |
| res | String? | Partial recognition result |
| result | String? | Complete recognition result |

### ASRDataType
```dart
enum ASRDataType {
  SLICE,
  SEGMENT,
  SUCCESS,
}
```

### ASRError
Error information during recognition.

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| code | int | Error code |
| message | String | Error message |
| resp | String? | Original server response |

## Custom Data Source
The SDK only handles speech recognition for input audio without additional processing. However, developers can implement custom data sources for audio processing (noise reduction, echo cancellation, etc.).

### Requirements
1. Data must be provided as `Stream<Uint8List>`
2. Audio format requirements:
   - Single channel
   - 16000Hz sampling rate
   - 16-bit
   - Little-endian PCM data
3. Data must be pushed to the stream every 40ms with 1280B of data
```
