import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/camera/camera_controller.dart';

/// OCR识别结果模型
class TextRecognitionResult {
  /// 识别到的完整文本
  final String fullText;
  
  /// 识别到的文本块列表
  final List<TextBlock> blocks;
  
  /// 识别的置信度 (0.0-1.0)
  final double confidence;
  
  /// 识别时间戳
  final DateTime timestamp;

  const TextRecognitionResult({
    required this.fullText,
    required this.blocks,
    required this.confidence,
    required this.timestamp,
  });
}

/// 文本块模型
/// 表示识别到的一个完整的文本区域
class TextBlock {
  /// 文本内容
  final String text;
  
  /// 文本块在图像中的位置
  final TextBlockBounds bounds;
  
  /// 文本块的类型（标题、段落、列表等）
  final TextBlockType type;
  
  /// 置信度 (0.0-1.0)
  final double confidence;
  
  /// 语言代码 (如 'zh-CN', 'en-US')
  final String? language;

  const TextBlock({
    required this.text,
    required this.bounds,
    required this.type,
    required this.confidence,
    this.language,
  });
}

/// 文本块边界
class TextBlockBounds {
  /// 左上角x坐标 (相对坐标 0.0-1.0)
  final double left;
  
  /// 左上角y坐标 (相对坐标 0.0-1.0)
  final double top;
  
  /// 右下角x坐标 (相对坐标 0.0-1.0)
  final double right;
  
  /// 右下角y坐标 (相对坐标 0.0-1.0)
  final double bottom;

  const TextBlockBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// 获取文本块的宽度
  double get width => right - left;

  /// 获取文本块的高度
  double get height => bottom - top;
}

/// 文本块类型
enum TextBlockType {
  /// 标题
  title,
  
  /// 段落
  paragraph,
  
  /// 列表项
  listItem,
  
  /// 表格单元格
  tableCell,
  
  /// 图片说明
  caption,
  
  /// 其他
  other,
}

/// 文字识别服务接口
/// 负责处理OCR相关的核心业务逻辑
abstract class TextRecognitionService {
  /// 初始化服务
  Future<void> initialize();

  /// 开始实时文字识别
  /// 返回文字识别结果流
  Stream<TextRecognitionResult> startRealtimeRecognition();

  /// 停止实时文字识别
  Future<void> stopRealtimeRecognition();

  /// 识别单帧图像
  /// [frame] 要识别的相机帧
  /// [options] 识别配置选项
  Future<TextRecognitionResult> recognizeSingleFrame(
    CameraFrame frame, {
    TextRecognitionOptions? options,
  });

  /// 获取当前识别状态
  TextRecognitionState get currentState;

  /// 释放资源
  Future<void> dispose();
}

/// 文字识别状态
enum TextRecognitionState {
  /// 未初始化
  uninitialized,
  
  /// 准备就绪
  ready,
  
  /// 正在识别
  recognizing,
  
  /// 识别完成
  completed,
  
  /// 发生错误
  error,
}

/// 文字识别配置选项
class TextRecognitionOptions {
  /// 识别的目标语言列表
  final List<String> targetLanguages;
  
  /// 最小文本块置信度阈值 (0.0-1.0)
  final double minConfidence;
  
  /// 是否启用文本块分类
  final bool enableBlockClassification;
  
  /// 是否启用语言检测
  final bool enableLanguageDetection;

  const TextRecognitionOptions({
    this.targetLanguages = const ['zh-CN', 'en-US'],
    this.minConfidence = 0.5,
    this.enableBlockClassification = true,
    this.enableLanguageDetection = true,
  });
}
