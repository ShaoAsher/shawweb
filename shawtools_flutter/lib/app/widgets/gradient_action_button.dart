import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 渐变操作按钮组件
/// 提供统一的按钮样式和动画效果，参照 JSON 格式化工具页面的按钮样式
class GradientActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool isTablet;
  final bool enableAnimation;

  const GradientActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
    this.isTablet = false,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 14 : 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isTablet ? 20 : 18, color: Colors.white),
                SizedBox(width: isTablet ? 8 : 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (enableAnimation) {
      return button
          .animate()
          .scale(delay: 100.ms, duration: 200.ms)
          .then()
          .shimmer(duration: 1000.ms);
    }
    return button;
  }
}
