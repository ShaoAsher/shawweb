import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX 弹窗工具类
/// 统一使用 Get.dialog 管理所有弹窗的显示和关闭
class GetXDialogUtils {
  static int _dialogCounter = 0;
  static final Map<int, String> _openDialogs = {};

  /// 显示底部弹窗（Bottom Sheet）
  ///
  /// [child] 弹窗内容
  /// [barrierDismissible] 点击背景是否关闭
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    final dialogId = ++_dialogCounter;
    final dialogName = 'BottomSheet_$dialogId';
    _openDialogs[dialogId] = dialogName;

    return Get.dialog<T>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Get.theme.cardColor,
          child: Container(
            constraints: BoxConstraints(maxHeight: Get.height * 0.9),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖拽指示器
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: Get.theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(child: child),
                // 底部安全区域填充，确保底部不透明
                Container(
                  height: MediaQuery.of(Get.context!).padding.bottom,
                  color: Get.theme.cardColor,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
    ).then((result) {
      _openDialogs.remove(dialogId);
      return result;
    });
  }

  /// 显示 iOS 风格弹窗（Cupertino Modal）
  ///
  /// [child] 弹窗内容
  /// [height] 弹窗高度（0-1 之间的比例，0.8 表示 80%）
  /// [barrierDismissible] 点击背景是否关闭
  static Future<T?> showCupertinoModal<T>({
    required Widget child,
    double height = 0.8,
    bool barrierDismissible = true,
  }) {
    final dialogId = ++_dialogCounter;
    final dialogName = 'CupertinoModal_$dialogId';
    _openDialogs[dialogId] = dialogName;

    return Get.dialog<T>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Get.theme.scaffoldBackgroundColor,
          child: Container(
            height: Get.height * height,
            decoration: BoxDecoration(
              color: Get.theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Expanded(child: child),
                // 底部安全区域填充，确保底部不透明
                Container(
                  height: MediaQuery.of(Get.context!).padding.bottom,
                  color: Get.theme.scaffoldBackgroundColor,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
    ).then((result) {
      _openDialogs.remove(dialogId);
      return result;
    });
  }

  /// 显示颜色选择弹窗
  ///
  /// [initialColor] 初始颜色
  /// [title] 标题
  static Future<Color?> showColorPicker({Color? initialColor, String? title}) {
    final dialogId = ++_dialogCounter;
    final dialogName = 'ColorPicker_$dialogId';
    _openDialogs[dialogId] = dialogName;

    return Get.dialog<Color>(
      Dialog(
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: Get.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ColorPicker(
                  initialColor: initialColor ?? Colors.blue,
                  onColorChanged: (color) {
                    Get.back(result: color);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    ).then((result) {
      _openDialogs.remove(dialogId);
      return result;
    });
  }

  /// 关闭当前弹窗
  ///
  /// [result] 返回结果
  static void close<T>([T? result]) {
    if (Get.isDialogOpen ?? false) {
      Get.back<T>(result: result);
    }
  }

  /// 获取当前打开的弹窗数量（用于调试）
  static int get openDialogCount => _openDialogs.length;

  /// 获取当前打开的弹窗列表（用于调试）
  static List<String> get openDialogs => _openDialogs.values.toList();
}

/// 简单的颜色选择器组件
class ColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _colors.length,
      itemBuilder: (context, index) {
        final color = _colors[index];
        final isSelected = selectedColor.value == color.value;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = color;
            });
            widget.onColorChanged(color);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }

  static const List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];
}
