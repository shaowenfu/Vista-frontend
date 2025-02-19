import 'package:flutter/material.dart';
import '../../../shared/constants.dart';
import '../../../shared/widgets/accessible_button.dart';

/// 主页面
/// 作为应用的主入口，提供对各个功能模块的导航
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: AppTextStyles.h1.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '请选择功能',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingLarge),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimensions.spacingMedium,
                  crossAxisSpacing: AppDimensions.spacingMedium,
                  children: [
                    _buildFeatureCard(
                      context,
                      title: AppStrings.sceneUnderstanding,
                      icon: Icons.landscape,
                      color: AppColors.primary,
                      route: '/scene',
                      description: '识别和描述周围环境',
                    ),
                    _buildFeatureCard(
                      context,
                      title: AppStrings.textRecognition,
                      icon: Icons.text_fields,
                      color: AppColors.secondary,
                      route: '/ocr',
                      description: '识别和朗读文字内容',
                    ),
                    _buildFeatureCard(
                      context,
                      title: AppStrings.objectDetection,
                      icon: Icons.search,
                      color: AppColors.accent,
                      route: '/object',
                      description: '检测和识别周围物体',
                    ),
                    _buildFeatureCard(
                      context,
                      title: '设置',
                      icon: Icons.settings,
                      color: AppColors.info,
                      route: '/settings',
                      description: '调整应用配置',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingMedium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              Text(
                title,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSmall),
              Text(
                description,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
