import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// API客户端提供者
/// 负责创建和管理API客户端实例
final apiClientProvider = Provider<ApiClient>((ref) {
  return HttpApiClient();
});

/// API客户端接口
/// 定义与后端通信的方法
abstract class ApiClient {
  /// 分析场景
  /// 发送图像数据到后端进行场景分析
  Future<Map<String, dynamic>> analyzeScene(List<int> imageBytes);
  
  /// 识别文字
  /// 发送图像数据到后端进行OCR文字识别
  Future<Map<String, dynamic>> recognizeText(List<int> imageBytes);
  
  /// 检测物体
  /// 发送图像数据到后端进行物体检测
  Future<Map<String, dynamic>> detectObjects(List<int> imageBytes);
  
  /// 语音识别
  /// 发送录音数据到后端进行语音识别和指令解析
  Future<Map<String, dynamic>> recognizeVoice(List<int> audioBytes);
}

/// HTTP API客户端实现
class HttpApiClient implements ApiClient {
  // TODO: 从配置文件或环境变量中获取API基础URL
  final String _baseUrl = 'http://localhost:8000/api';
  final http.Client _httpClient = http.Client();
  
  @override
  Future<Map<String, dynamic>> analyzeScene(List<int> imageBytes) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/scene/analyze'),
        headers: {
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('场景分析失败: ${response.statusCode}');
      }
    } catch (e) {
      // 在实际应用中，应该使用更好的错误处理机制
      print('场景分析错误: $e');
      return {'error': e.toString()};
    }
  }
  
  @override
  Future<Map<String, dynamic>> recognizeText(List<int> imageBytes) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/ocr/recognize'),
        headers: {
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('文字识别失败: ${response.statusCode}');
      }
    } catch (e) {
      print('文字识别错误: $e');
      return {'error': e.toString()};
    }
  }
  
  @override
  Future<Map<String, dynamic>> detectObjects(List<int> imageBytes) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/object/detect'),
        headers: {
          'Content-Type': 'application/octet-stream',
        },
        body: imageBytes,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('物体检测失败: ${response.statusCode}');
      }
    } catch (e) {
      print('物体检测错误: $e');
      return {'error': e.toString()};
    }
  }
  
  @override
  Future<Map<String, dynamic>> recognizeVoice(List<int> audioBytes) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/voice/recognize'),
        headers: {
          'Content-Type': 'audio/wav', // 或其他适当的音频格式
        },
        body: audioBytes,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('语音识别失败: ${response.statusCode}');
      }
    } catch (e) {
      print('语音识别错误: $e');
      return {'error': e.toString()};
    }
  }
  
  /// 释放资源
  void dispose() {
    _httpClient.close();
  }
}
