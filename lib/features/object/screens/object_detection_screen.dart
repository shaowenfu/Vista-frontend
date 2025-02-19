import 'package:flutter/material.dart';
import '../../../shared/constants.dart';
import '../../../shared/widgets/accessible_button.dart';

/// 物体检测页面
/// 用于展示物体检测功能的主界面
class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  bool _isDetecting = false;
  List<DetectedObjectInfo> _detectedObjects = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.objectDetection,
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: Text(
                      '相机预览区域 - 待实现',
                      style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                // TODO: 添加物体检测框的绘制层
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            color: AppColors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetectionList(),
                const SizedBox(height: AppDimensions.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AccessibleButton(
                      label: _isDetecting ? '停止检测' : '开始检测',
                      onPressed: _toggleDetection,
                      icon: _isDetecting ? Icons.stop : Icons.search,
                      color: _isDetecting ? AppColors.error : AppColors.primary,
                    ),
                    AccessibleButton(
                      label: '拍摄照片',
                      onPressed: _captureImage,
                      icon: Icons.camera,
                      color: AppColors.secondary,
                    ),
                    AccessibleButton(
                      label: '朗读结果',
                      onPressed: _speakResults,
                      icon: Icons.volume_up,
                      color: AppColors.info,
                      enableVoice: false, // 避免与朗读功能冲突
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionList() {
    if (_detectedObjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          '检测到的物体将在这里显示',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _detectedObjects.length,
        itemBuilder: (context, index) {
          final object = _detectedObjects[index];
          return ListTile(
            leading: Icon(
              Icons.check_circle,
              color: AppColors.success,
            ),
            title: Text(
              object.name,
              style: AppTextStyles.bodyMedium,
            ),
            subtitle: Text(
              '置信度: ${(object.confidence * 100).toStringAsFixed(1)}%',
              style: AppTextStyles.caption,
            ),
            trailing: Text(
              object.distance != null
                  ? '距离: ${object.distance!.toStringAsFixed(1)}米'
                  : '',
              style: AppTextStyles.caption,
            ),
          );
        },
      ),
    );
  }

  void _toggleDetection() {
    // TODO: 实现物体检测的开始/停止
    setState(() {
      _isDetecting = !_isDetecting;
      // 测试数据
      if (_isDetecting) {
        _detectedObjects = [
          DetectedObjectInfo(
            name: '椅子',
            confidence: 0.95,
            distance: 1.5,
          ),
          DetectedObjectInfo(
            name: '桌子',
            confidence: 0.88,
            distance: 2.0,
          ),
        ];
      } else {
        _detectedObjects.clear();
      }
    });
  }

  void _captureImage() {
    // TODO: 实现拍摄照片功能
  }

  void _speakResults() {
    // TODO: 实现检测结果朗读功能
    if (_detectedObjects.isEmpty) {
      // TODO: 提示用户没有检测结果
      return;
    }
    // TODO: 组织并朗读检测结果
  }
}

/// 检测到的物体信息
class DetectedObjectInfo {
  final String name;
  final double confidence;
  final double? distance;
  final String? description;

  DetectedObjectInfo({
    required this.name,
    required this.confidence,
    this.distance,
    this.description,
  });
}
