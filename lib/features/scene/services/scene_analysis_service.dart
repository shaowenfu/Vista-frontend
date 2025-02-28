import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/communication/api_client.dart';

/// 场景分析服务提供者
/// 负责创建和管理场景分析服务实例
final sceneAnalysisServiceProvider = Provider<SceneAnalysisService>((ref) {
  print('[SceneAnalysis] 初始化场景分析服务...');
  final apiClient = ref.watch(apiClientProvider);
  final service = SceneAnalysisService(apiClient);
  print('[SceneAnalysis] 场景分析服务初始化完成');
  return service;
});

/// 场景分析服务
/// 负责处理场景分析相关的业务逻辑
class SceneAnalysisService {
  final ApiClient _apiClient;
  
  SceneAnalysisService(this._apiClient);
  
  /// 分析场景
  /// 发送图像数据到后端进行场景分析
  Future<SceneAnalysisResult> analyzeScene(Uint8List imageBytes) async {
    print('[SceneAnalysis] 开始场景分析...');
    
    try {
      print('[SceneAnalysis] 准备发送图像数据，大小: ${imageBytes.length} bytes');
      
      print('[SceneAnalysis] 调用API进行场景分析...');
      final response = await _apiClient.analyzeScene(imageBytes);
      print('[SceneAnalysis] API响应成功，开始解析结果...');
      
      final result = SceneAnalysisResult.fromJson(response);
      print('[SceneAnalysis] 场景分析成功: ${result.description}');
      return result;
    } catch (e) {
      print('[SceneAnalysis] 场景分析出错: $e');
      return SceneAnalysisResult(
        description: '场景分析失败: $e',
        confidence: 0.0,
        objects: [],
        error: true,
      );
    }
  }
}

/// 场景分析结果
/// 包含场景分析的结果信息
class SceneAnalysisResult {
  final String description;
  final double confidence;
  final List<DetectedObject> objects;
  final bool error;
  
  SceneAnalysisResult({
    required this.description,
    required this.confidence,
    required this.objects,
    this.error = false,
  });
  
  /// 从JSON创建场景分析结果
  factory SceneAnalysisResult.fromJson(Map<String, dynamic> json) {
    print('[SceneAnalysis] 解析场景分析结果...');
    
    if (json.containsKey('error')) {
      print('[SceneAnalysis] 发现错误响应: ${json['error']}');
      return SceneAnalysisResult(
        description: json['error'],
        confidence: 0.0,
        objects: [],
        error: true,
      );
    }
    
    print('[SceneAnalysis] 解析检测到的物体...');
    final List<dynamic> objectsJson = json['objects'] ?? [];
    final List<DetectedObject> objects = objectsJson
        .map((obj) => DetectedObject.fromJson(obj))
        .toList();
    
    print('[SceneAnalysis] 解析完成，描述: ${json['description']}，置信度: ${json['confidence']}');
    return SceneAnalysisResult(
      description: json['description'] ?? '无法识别场景',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      objects: objects,
    );
  }
}

/// 检测到的物体
/// 包含物体的类型、位置和置信度
class DetectedObject {
  final String label;
  final double confidence;
  final BoundingBox boundingBox;
  
  DetectedObject({
    required this.label,
    required this.confidence,
    required this.boundingBox,
  });
  
  /// 从JSON创建检测到的物体
  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    print('[SceneAnalysis] 解析检测到的物体: ${json['label']}');
    return DetectedObject(
      label: json['label'] ?? '未知物体',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      boundingBox: BoundingBox.fromJson(json['bounding_box'] ?? {}),
    );
  }
}

/// 边界框
/// 包含物体在图像中的位置信息
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  
  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
  
  /// 从JSON创建边界框
  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    print('[SceneAnalysis] 解析边界框: '
        'x=${json['x']}, y=${json['y']}, '
        'width=${json['width']}, height=${json['height']}');
    return BoundingBox(
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
      width: (json['width'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
    );
  }
}
