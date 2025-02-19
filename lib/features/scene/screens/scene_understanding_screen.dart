import 'package:flutter/material.dart';
import '../../../shared/constants.dart';
import '../../../shared/widgets/accessible_button.dart';

/// 场景理解页面
/// 用于展示场景理解功能的主界面
class SceneUnderstandingScreen extends StatefulWidget {
  const SceneUnderstandingScreen({super.key});

  @override
  State<SceneUnderstandingScreen> createState() => _SceneUnderstandingScreenState();
}

class _SceneUnderstandingScreenState extends State<SceneUnderstandingScreen> {
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.sceneUnderstanding,
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Text(
                  '相机预览区域 - 待实现',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMedium),
            color: AppColors.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '场景描述将在这里显示',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppDimensions.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AccessibleButton(
                      label: _isAnalyzing ? '停止分析' : '开始分析',
                      onPressed: _toggleAnalysis,
                      icon: _isAnalyzing ? Icons.stop : Icons.play_arrow,
                      color: _isAnalyzing ? AppColors.error : AppColors.primary,
                    ),
                    AccessibleButton(
                      label: '拍摄照片',
                      onPressed: _captureImage,
                      icon: Icons.camera,
                      color: AppColors.secondary,
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

  void _toggleAnalysis() {
    // TODO: 实现场景分析的开始/停止
    setState(() {
      _isAnalyzing = !_isAnalyzing;
    });
  }

  void _captureImage() {
    // TODO: 实现拍摄照片功能
  }
}
