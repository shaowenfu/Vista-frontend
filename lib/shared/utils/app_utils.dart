import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 应用工具类
/// 提供各种通用的辅助函数
class AppUtils {
  /// 格式化时间戳为可读字符串
  /// [timestamp] 时间戳
  /// [format] 是否使用完整格式（默认简略格式）
  static String formatTimestamp(DateTime timestamp, {bool format = false}) {
    if (format) {
      return '${timestamp.year}-${_pad(timestamp.month)}-${_pad(timestamp.day)} '
          '${_pad(timestamp.hour)}:${_pad(timestamp.minute)}:${_pad(timestamp.second)}';
    }
    return '${_pad(timestamp.month)}-${_pad(timestamp.day)} '
        '${_pad(timestamp.hour)}:${_pad(timestamp.minute)}';
  }

  /// 数字补零
  static String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }

  /// 计算两点之间的距离
  /// [point1], [point2] 两个点的坐标
  static double calculateDistance(Point point1, Point point2) {
    final dx = point1.x - point2.x;
    final dy = point1.y - point2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// 检查字符串是否为空或空白
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// 获取文件扩展名
  /// [fileName] 文件名
  static String getFileExtension(String fileName) {
    return fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
  }

  /// 格式化文件大小
  /// [bytes] 文件大小（字节）
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// 生成随机颜色
  static Color generateRandomColor({int? seed}) {
    final random = seed != null ? math.Random(seed) : math.Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  /// 检查是否为有效的电子邮件地址
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  /// 检查是否为有效的手机号码（中国大陆）
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  /// 截断文本
  /// [text] 原始文本
  /// [maxLength] 最大长度
  /// [suffix] 截断后的后缀
  static String truncateText(
    String text,
    int maxLength, {
    String suffix = '...',
  }) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  /// 防抖函数
  /// [callback] 需要防抖的函数
  /// [duration] 防抖时间
  static Function debounce(
    Function callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    Timer? timer;
    return () {
      if (timer != null) {
        timer!.cancel();
      }
      timer = Timer(duration, () => callback());
    };
  }

  /// 节流函数
  /// [callback] 需要节流的函数
  /// [duration] 节流时间
  static Function throttle(
    Function callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    DateTime? lastTime;
    return () {
      final now = DateTime.now();
      if (lastTime == null ||
          now.difference(lastTime!) > duration) {
        callback();
        lastTime = now;
      }
    };
  }

  /// 深度比较两个对象是否相等
  static bool deepEquals(dynamic obj1, dynamic obj2) {
    if (identical(obj1, obj2)) return true;
    if (obj1 == null || obj2 == null) return false;
    if (obj1.runtimeType != obj2.runtimeType) return false;

    if (obj1 is List) {
      if (obj2 is! List || obj1.length != obj2.length) return false;
      for (var i = 0; i < obj1.length; i++) {
        if (!deepEquals(obj1[i], obj2[i])) return false;
      }
      return true;
    }

    if (obj1 is Map) {
      if (obj2 is! Map || obj1.length != obj2.length) return false;
      for (var key in obj1.keys) {
        if (!obj2.containsKey(key) ||
            !deepEquals(obj1[key], obj2[key])) {
          return false;
        }
      }
      return true;
    }

    return obj1 == obj2;
  }
}

/// 二维坐标点
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
