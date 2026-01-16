import 'package:flutter/material.dart';

import '../../widgets/tool_page_wrapper.dart';

class PlaceholderToolPage extends StatelessWidget {
  final String title;
  final String titleEn;

  const PlaceholderToolPage({
    super.key,
    required this.title,
    required this.titleEn,
  });

  @override
  Widget build(BuildContext context) {
    return ToolPageWrapper(
      title: title,
      titleEn: titleEn,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '功能开发中...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon...',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
