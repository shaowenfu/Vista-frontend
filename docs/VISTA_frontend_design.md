# VISTA 前端设计文档

本设计文档针对 VISTA 项目前端进行了全面重构，以满足 BLV（盲人或低视力）人群的使用需求。我们遵循“尽可能降低 BLV 人群的使用门槛”的开发原则，重新定义了模块化架构、交互方式和实现步骤。

---

## **一、核心开发原则**
1. **无障碍优先**:
   - 用户与应用的主要交互方式为语音指令和触觉反馈。
   - 避免依赖视觉界面，确保所有功能均可通过语音或无障碍技术完成。

2. **单一页面设计**:
   - 应用仅包含一个页面：相机页面。
   - 用户打开应用后，直接进入相机模式，无需额外导航。

3. **语音驱动功能切换**:
   - 用户通过语音指令切换功能（如场景理解、文字识别、物体检测）。
   - 提供清晰的语音反馈，告知用户当前状态和操作结果。

4. **触觉反馈增强体验**:
   - 使用震动反馈确认用户操作，提升交互的直观性。

---

## **二、模块化开发**

### **1. 模块划分与职责**
```plaintext
1. **核心功能模块**
   - CameraModule: 相机控制与帧捕获
   - VoiceModule: 语音指令识别与合成
   - HapticModule: 触觉反馈控制

2. **业务逻辑模块**
   - SceneUnderstandingService: 场景理解流程管理
   - OCRService: 文字识别与格式化
   - ObjectDetectionService: 物体检测与描述生成

3. **视频流处理模块**
   这个是前端的重要创新点--关键帧提取技术
   为了减轻通信压力和后端负担，前端需要处理视频流，并进行必要的预处理和压缩，以确保视频流的质量和传输效率。最重要的是，根据任务的不同，前端需要对视频流进行不同的处理，以确保任务的准确性和效率。
   比如：
   - 场景理解：需要对视频流进行压缩和编码，以确保视频流的质量和传输效率。
   - 文字识别：需要提取关键帧，然后只发送关键帧，以确保文字识别的准确性和效率。
   - 物体检测：需要提取关键帧，然后只发送关键帧，以确保物体检测的准确性和效率。


4. **无障碍交互模块**
   - VoiceInteractionManager: 管理语音指令解析与响应
   - HapticFeedbackManager: 管理触觉反馈逻辑
```

---

## **三、系统设计**

### **1. 项目目录结构**

---

### **2. 功能模块说明**

#### **1. `lib/` 目录**

- **`main.dart`**:
  - **内容**: 应用的入口文件。
  - **作用**: 初始化应用，启动无障碍友好的相机页面。

- **`app/` 目录**:
  - **`app.dart`**:
    - **内容**: 应用的初始化逻辑。
    - **作用**: 配置全局无障碍支持、语音模块和触觉反馈模块。
  - **`routes.dart`**:
    - **内容**: 简化的路由配置，仅支持单页面（相机页面）。

- **`core/` 目录**:
  - 内容：功能模块
- **`core/voice/` 目录**:
    - **`voice_module.dart`**:
      - **内容**: 语音合成服务实现。
      - **作用**: 负责文本到语音的转换，提供自然的语音反馈。
      - **核心功能**:
        - 语音合成（TTS）
        - 语音参数配置（语速、音量、音调等）
        - 多语言支持
        - 语音队列管理
    - **`continuous_voice_service.dart`**:
      - **内容**: 持续语音监听服务实现。
      - **作用**: 负责后台持续监听用户语音，检测唤醒词并自动录音。
      - **核心功能**:
        - 唤醒词检测（使用Porcupine引擎）
        - 语音活动检测（VAD）
        - 自动录音与停止
        - 录音文件处理与上传
        - 状态管理与视觉反馈
        
- **`communication/` 目录**:
  - **`api_client.dart`**:
    - **内容**: API 客户端逻辑。
    - **作用**: 封装与后端通信的逻辑，支持 HTTP 请求和 WebSocket。


- **`local_storage.dart`**:
  - **内容**: 本地存储逻辑。
  - **作用**: 实现数据的缓存和持久化。

#### **2. `assets/` 目录**
- **内容**: 静态资源，如图片、图标。
- **作用**: 存放应用中使用的所有静态文件。

#### **3. `test/` 目录**
- **内容**: 测试文件。
- **作用**: 包含应用的单元测试和集成测试，确保代码的正确性和稳定性。

### **3.核心功能模块的调用流程

 <mcsymbol name="_CameraScreenState" filename="camera_screen.dart" path="e:\all_workspace\VISTA\vista_frontend\lib\camera_screen.dart" startline="37" type="class"></mcsymbol> 中各个核心功能模块是如何被调用的：

## 1. 权限管理模块

权限管理模块的调用流程：

```
initState() → _requestPermissions() → _checkAndRequestPermissions() / _checkAndRequestAudioPermissions()
```

- 在 `initState()` 中调用 `_requestPermissions()`，这是应用启动时的入口点
- `_requestPermissions()` 会同时检查相机和音频权限
- 如果权限未获取，会设置一个定时器每5秒重新检查权限

## 2. 帧处理模块

场景分析模块的调用流程：

```
_checkAndRequestPermissions() → _startFrameHadleTimer() → _analyzeCurrentFrame() → _analyzeScene()
```

- 当获取到相机权限后，`_checkAndRequestPermissions()` 会调用 `_startFrameHadleTimer()`
- 定时器每3秒触发一次 `_analyzeCurrentFrame()`
- 根据当前模式 `_currentMode`，调用相应的分析方法（目前只实现了 `_analyzeScene()`）
- 分析成功后，通过触觉反馈模块提供反馈

另外，帧处理模块还会在应用生命周期变化时被控制：
- 当应用进入后台（`AppLifecycleState.paused`）时，停止分析
- 当应用恢复前台（`AppLifecycleState.resumed`）时，重新开始分析

## 3. 音频录制模块

音频录制模块的调用流程：

```
initState() → _initAudioRecorder()
```

以及用户交互触发的流程：

```
GestureDetector.onLongPressStart → _longPressTimer → _startRecording()
GestureDetector.onLongPressEnd → _stopRecording() → _sendAudioToBackend()
```

- 在 `initState()` 中初始化录音器
- 用户长按屏幕3秒后，触发 `_startRecording()`
- 用户松开长按时，触发 `_stopRecording()`，然后调用 `_sendAudioToBackend()`（目前是待实现的TODO）

## 4. 资源清理模块

资源清理在以下情况被调用：

```
dispose() → _stopAnalysisTimer() / _permissionTimer?.cancel() / _disposeAudioRecorder()
```

- 当组件被销毁时，`dispose()` 方法会被调用
- 它会停止所有定时器、取消权限检查、关闭录音器

## 5. 生命周期管理

生命周期管理通过 `WidgetsBindingObserver` 实现：

```
didChangeAppLifecycleState() → 根据状态调用 _stopAnalysisTimer() / _startFrameHadleTimer() / _stopRecording()
```

- 当应用状态变化时，`didChangeAppLifecycleState()` 被系统调用
- 根据不同状态执行相应操作，确保资源合理使用

## 6. UI 渲染

UI 渲染通过 `build()` 方法实现：

```
build() → GestureDetector → Scaffold → ref.watch(cameraControllerProvider).when()
```

- 使用 Riverpod 的 `ref.watch()` 监听相机控制器状态
- 根据状态显示相机预览或加载/错误界面
- 通过 `GestureDetector` 捕获用户长按手势

---

## **四、功能实现细节**

- **页面描述**:
  - 用户打开应用后，直接进入相机页面。
  - 页面无视觉 UI，支持语音指令和触觉反馈交互。
  - 新增长按录音功能区域

- **交互流程**:
  1. 基础交互:
     - 用户打开应用，自动启动相机。
     - 用户发出语音指令（如“分析场景”、“识别文字”、“检测物体”）。
     - 应用通过语音反馈告知用户当前操作状态和结果。
     - 提供触觉反馈确认操作完成。
  
  2. 长按录音交互:
     - 用户长按屏幕任意位置超过3秒开始录音
     - 触发振动反馈确认录音开始
     - 用户松手时结束录音
     - 录音文件自动上传至后端处理
     - 后端返回处理结果后，通过语音播报反馈给用户

### **录音交互实现**

1. **触发条件**:
   - 手动模式：长按屏幕任意位置超过3秒，松手结束录音
   - 自动模式：启用持续监听后，说出唤醒词"嘿，Vista"自动开始录音，静音2秒后自动结束录音

2. **实现细节**:
   ```dart
   GestureDetector(
     onLongPressStart: (details) {
       _startRecording();
     },
     onLongPressEnd: (details) {
       _stopRecording();
     },
     child: Container(
       // 全屏可触控区域
     ),
   )
   
   Future<void> _startRecording() async {
     final tempDir = Directory.systemTemp;
     final filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
     await _audioRecorder.startRecorder(
       toFile: filePath,
       codec: Codec.aacADTS,
     );
   }
   
   Future<void> _stopRecording() async {
     final result = await _audioRecorder.stopRecorder();
     if (result != null) {
       _sendAudioToBackend(result);
     }
   }
   ···
  

3. **前后端交互**:
   - 前端不再进行本地语音识别
   - 录音文件直接发送到后端 `/api/voice/recognize`
   - 后端返回识别结果和对应的操作指令

### **音频处理实现**

1. **技术选型**:
   - 使用 `flutter_sound` 包实现音频录制和会话管理
   - 使用 `flutter_tts` 包实现文本到语音的转换
   - 使用腾讯云语音服务进行语音合成：https://cloud.tencent.com/document/product/1093/86888
   
2. **音频会话管理**:
   ```dart
   class AudioService {
     final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
     
     Future<void> initAudioSession() async {
       await _audioRecorder.openRecorder();
     }
     
     Future<void> closeAudioSession() async {
       await _audioRecorder.closeRecorder();
     }
     
     Future<void> startRecording(String filePath) async {
       await _audioRecorder.startRecorder(
         toFile: filePath,
         codec: Codec.aacADTS,
       );
     }
     
     Future<void> stopRecording() async {
       await _audioRecorder.stopRecorder();
     }
   }
   ```

3. **语音播报实现**:
   - 支持 Android (TextToSpeech) 和 iOS (AVSpeechSynthesizer) 平台

4. **核心功能**:
   ```dart
   class VoiceService {
     final FlutterTts tts = FlutterTts();
     
     Future<void> initialize() async {
       await tts.setLanguage('zh-CN');
       await tts.setSpeechRate(1.0);
       await tts.setVolume(1.0);
       await tts.setPitch(1.0);
     }
     
     Future<void> speak(String text) async {
       await tts.speak(text);
     }
   }
   ```
5. **使用场景**:
   - 场景分析结果播报
   - 文字识别结果播报
   - 物体检测结果播报
   - 错误状态提示
   - 操作确认反馈
6. **优化策略:**
   - 语音队列管理，避免语音重叠
   - 智能中断机制，优先播报重要信息
   - 根据场景动态调整语速
   - 支持紧急打断当前播报
7. **无障碍增强 :**
   - 提供清晰的语音指令反馈
   - 支持语音音量和语速的个性化设置
   - 结合触觉反馈提供多感官体验
   - 智能调整语音提示的详细程度

### **持续语音监听实现**

1. **技术选型**:
   - 使用 `porcupine_flutter` 包实现唤醒词检测
   - 使用 `flutter_sound` 包实现音频录制和活动检测
   - 使用 `path_provider` 包管理临时文件

2. **唤醒词检测**:
   ```dart
   class ContinuousVoiceService {
     PorcupineManager? _porcupineManager;
     
     Future<void> _initializeWakeWordDetection() async {
       _porcupineManager = await PorcupineManager.fromKeywordPaths(
         "YOUR_PORCUPINE_ACCESS_KEY",
         ["assets/wake_words/hey_vista_zh.ppn"], // 唤醒词模型文件路径
         _onWakeWordDetected,
         errorCallback: (PorcupineException error) {
           _logger.severe('唤醒词检测错误: ${error.message}');
         },
       );
       
       await _porcupineManager?.start();
     }
     
     void _onWakeWordDetected(int keywordIndex) {
       // 播放提示音
       final voiceService = _ref.read(voiceCommandProvider);
       voiceService.speak('我在听');
       
       // 开始录音
       startRecording();
     }
   }
   ```

3. **语音活动检测**:
   ```dart
   void _checkSilence() {
     if (_lastVoiceActivityTime == null || !_recorder.isRecording) return;
     
     final now = DateTime.now();
     final silenceDuration = now.difference(_lastVoiceActivityTime!).inMilliseconds;
     
     if (silenceDuration > _silenceThresholdMs) {
       _logger.info('检测到${_silenceThresholdMs}ms静音，自动停止录音');
       stopRecording();
     }
   }
   ```

4. **状态管理**:
   - 使用 Riverpod 的 StateProvider 管理持续监听状态
   - 提供视觉反馈指示当前状态（空闲/监听中/录音中/处理中）
   - 支持通过浮动按钮开启/关闭持续监听功能

5. **生命周期管理**:
   - 应用进入后台时暂停监听
   - 应用恢复前台时恢复监听
   - 组件销毁时释放所有资源

    
## **五、前后端协同设计**

### **通信协议封装**
```dart
// API 客户端抽象层
abstract class ApiClient {
  Future<SceneAnalysisResult> analyzeScene(CameraFrame frame);
  Future<OcrResult> recognizeText(Uint8List image);
}

// 示例实现
class WebSocketClient implements ApiClient {
  final WebSocketChannel _channel;

  @override
  Future<SceneAnalysisResult> analyzeScene(CameraFrame frame) async {
    _channel.sink.add(frame.toJson());
    return await _channel.stream
        .where((data) => data['type'] == 'scene_analysis')
        .first;
  }
}
```

---

## **六、总结**
通过以上设计，我们实现了无障碍优先的前端架构，确保 BLV 人群能够轻松使用 VISTA 应用。所有功能均通过语音指令和触觉反馈完成，避免了对视觉界面的依赖。
