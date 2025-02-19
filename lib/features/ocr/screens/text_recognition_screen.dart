import 'package:flutter/material.dart';
import '../../../shared/constants.dart';
import '../../../shared/widgets/accessible_button.dart';

/// 文字识别页面
/// 用于展示OCR文字识别功能的主界面
class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  bool _isRecognizing = false;
  String _recognizedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.textRecognition,
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
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
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              color: AppColors.surface,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _recognizedText.isEmpty
                              ? '识别到的文本将在这里显示'
                              : _recognizedText,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AccessibleButton(
                        label: _isRecognizing ? '停止识别' : '开始识别',
                        onPressed: _toggleRecognition,
                        icon: _isRecognizing ? Icons.stop : Icons.text_fields,
                        color: _isRecognizing ? AppColors.error : AppColors.primary,
                      ),
                      AccessibleButton(
                        label: '拍摄照片',
                        onPressed: _captureImage,
                        icon: Icons.camera,
                        color: AppColors.secondary,
                      ),
                      AccessibleButton(
                        label: '朗读文本',
                        onPressed: _speakText,
                        icon: Icons.volume_up,
                        color: AppColors.info,
                        enableVoice: false, // 避免与朗读功能冲突
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AccessibleFloatingActionButton(
        label: '清除文本',
        onPressed: _clearText,
        icon: Icons.delete_outline,
        backgroundColor: AppColors.error,
        mini: true,
      ),
    );
  }

  void _toggleRecognition() {
    // TODO: 实现文字识别的开始/停止
    setState(() {
      _isRecognizing = !_isRecognizing;
    });
  }

  void _captureImage() {
    // TODO: 实现拍摄照片功能
  }

  void _speakText() {
    // TODO: 实现文本朗读功能
    if (_recognizedText.isEmpty) {
      // TODO: 提示用户没有可朗读的文本
      return;
    }
  }

  void _clearText() {
    setState(() {
      _recognizedText = '';
    });
  }
}
