import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum TimestampStatusType {
  success,
  error,
}

class TimestampResultItem {
  final String label;
  final String value;

  TimestampResultItem(
    this.label,
    this.value,
  );
}

class TimestampConverterController
    extends
        GetxController {
  final timestampInput = ''.obs;
  final timestampType = 'auto'.obs;
  final dateInput = ''.obs;

  final dateTextController = TextEditingController();

  final timestampResults =
      <
            TimestampResultItem
          >[]
          .obs;
  final dateResults =
      <
            TimestampResultItem
          >[]
          .obs;
  final currentTimeResults =
      <
            TimestampResultItem
          >[]
          .obs;

  final statusText = ''.obs;
  final statusType =
      Rx<
        TimestampStatusType?
      >(
        null,
      );

  final _dateFormat = DateFormat(
    'yyyy-MM-dd HH:mm:ss',
  );

  void setTimestampInput(
    String value,
  ) {
    timestampInput.value = value;
  }

  void setTimestampType(
    String value,
  ) {
    timestampType.value = value;
  }

  void setDateInput(
    String value,
  ) {
    dateInput.value = value;
    dateTextController.text = value;
  }

  @override
  void onClose() {
    dateTextController.dispose();
    super.onClose();
  }

  void convertTimestamp() {
    final input = timestampInput.value.trim();
    if (input.isEmpty) {
      _setStatus(
        '请输入时间戳',
        TimestampStatusType.error,
      );
      timestampResults.clear();
      return;
    }

    final parsed = int.tryParse(
      input,
    );
    if (parsed ==
        null) {
      _setStatus(
        '时间戳格式错误',
        TimestampStatusType.error,
      );
      timestampResults.clear();
      return;
    }

    var ts = parsed;
    final type = timestampType.value;
    if (type ==
        'auto') {
      if (input.length <=
          10) {
        ts *= 1000;
      }
    } else if (type ==
        'second') {
      ts *= 1000;
    }

    DateTime date;
    try {
      date = DateTime.fromMillisecondsSinceEpoch(
        ts,
      );
    } catch (
      _
    ) {
      _setStatus(
        '时间戳无效',
        TimestampStatusType.error,
      );
      timestampResults.clear();
      return;
    }

    final local = date.toLocal();
    final utc = date.toUtc();

    final formattedDateTime = _dateFormat.format(
      local,
    );
    final formattedDate =
        DateFormat(
          'yyyy-MM-dd',
        ).format(
          local,
        );
    final formattedTime =
        DateFormat(
          'HH:mm:ss',
        ).format(
          local,
        );

    timestampResults
      ..clear()
      ..addAll(
        [
          TimestampResultItem(
            '日期时间',
            formattedDateTime,
          ),
          TimestampResultItem(
            '日期',
            formattedDate,
          ),
          TimestampResultItem(
            '时间',
            formattedTime,
          ),
          TimestampResultItem(
            'ISO 8601',
            local.toIso8601String(),
          ),
          TimestampResultItem(
            '本地时间',
            formattedDateTime,
          ),
          TimestampResultItem(
            'UTC 时间',
            DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).format(
              utc,
            ),
          ),
        ],
      );

    _setStatus(
      '转换成功',
      TimestampStatusType.success,
    );
  }

  void convertDateToTimestamp() {
    final input = dateInput.value.trim();
    if (input.isEmpty) {
      _setStatus(
        '请选择或输入日期时间',
        TimestampStatusType.error,
      );
      dateResults.clear();
      return;
    }

    DateTime date;
    try {
      date = _dateFormat.parse(
        input,
      );
    } catch (
      _
    ) {
      try {
        date = DateTime.parse(
          input,
        );
      } catch (
        _
      ) {
        _setStatus(
          '日期格式错误，请使用 yyyy-MM-dd HH:mm:ss',
          TimestampStatusType.error,
        );
        dateResults.clear();
        return;
      }
    }

    final ts = date.millisecondsSinceEpoch;
    final second =
        ts ~/
        1000;
    final millisecond = ts;

    dateResults
      ..clear()
      ..addAll(
        [
          TimestampResultItem(
            '时间戳（秒）',
            second.toString(),
          ),
          TimestampResultItem(
            '时间戳（毫秒）',
            millisecond.toString(),
          ),
        ],
      );

    _setStatus(
      '转换成功',
      TimestampStatusType.success,
    );
  }

  void generateCurrentTime() {
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch;
    final second =
        ts ~/
        1000;
    final formatted = _dateFormat.format(
      now,
    );

    currentTimeResults
      ..clear()
      ..addAll(
        [
          TimestampResultItem(
            '当前时间戳（秒）',
            second.toString(),
          ),
          TimestampResultItem(
            '当前时间戳（毫秒）',
            ts.toString(),
          ),
          TimestampResultItem(
            '日期时间',
            formatted,
          ),
          TimestampResultItem(
            'ISO 8601',
            now.toIso8601String(),
          ),
        ],
      );

    _setStatus(
      '已获取当前时间',
      TimestampStatusType.success,
    );
  }

  void setNowToDateInput() {
    final now = DateTime.now();
    setDateInput(
      _dateFormat.format(
        now,
      ),
    );
  }

  void clearStatus() {
    statusText.value = '';
    statusType.value = null;
  }

  void _setStatus(
    String text,
    TimestampStatusType type,
  ) {
    statusText.value = text;
    statusType.value = type;
  }
}
