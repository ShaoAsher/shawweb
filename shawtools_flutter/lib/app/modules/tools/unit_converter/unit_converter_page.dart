import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/tool_page_wrapper.dart';
import 'unit_converter_controller.dart';

class UnitConverterPage
    extends
        GetView<
          UnitConverterController
        > {
  const UnitConverterPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isTablet =
        MediaQuery.of(
          context,
        ).size.width >
        600;

    return ToolPageWrapper(
      title: '单位转换工具',
      titleEn: 'Unit Converter',
      child: LayoutBuilder(
        builder:
            (
              context,
              constraints,
            ) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in controller.groups.asMap().entries) ...[
                      _SectionCard(
                        icon: _iconForIndex(
                          entry.key,
                        ),
                        title: entry.value.title,
                        child: _UnitGroupCard(
                          controller: controller,
                          group: entry.value,
                          isTablet: isTablet,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ],
                ),
              );
            },
      ),
    );
  }

  IconData _iconForIndex(
    int index,
  ) {
    switch (index) {
      case 0:
        return Icons.straighten;
      case 1:
        return Icons.scale;
      case 2:
        return Icons.thermostat;
      case 3:
        return Icons.square_foot;
      case 4:
        return Icons.local_drink;
      case 5:
        return Icons.access_time;
      case 6:
        return Icons.speed;
      case 7:
        return Icons.storage;
      case 8:
        return Icons.rotate_90_degrees_ccw;
      case 9:
        return Icons.compress;
      default:
        return Icons.swap_horiz;
    }
  }
}

class _SectionCard
    extends
        StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardColor,
              theme.cardColor.withValues(
                alpha: 0.92,
              ),
            ],
          ),
        ),
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: theme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _UnitGroupCard
    extends
        StatefulWidget {
  final UnitConverterController controller;
  final UnitGroup group;
  final bool isTablet;

  const _UnitGroupCard({
    required this.controller,
    required this.group,
    required this.isTablet,
  });

  @override
  State<
    _UnitGroupCard
  >
  createState() => _UnitGroupCardState();
}

class _UnitGroupCardState
    extends
        State<
          _UnitGroupCard
        > {
  late final TextEditingController _inputController;
  late final TextEditingController _outputController;
  late UnitItem _fromUnit;
  late UnitItem _toUnit;
  String _summary = '';

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _outputController = TextEditingController();
    _fromUnit = widget.group.units.first;
    _toUnit =
        widget.group.units.length >
            1
        ? widget.group.units[1]
        : widget.group.units.first;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _performConversion() {
    final raw = _inputController.text.trim();
    if (raw.isEmpty) {
      setState(
        () {
          _outputController.text = '';
          _summary = '';
        },
      );
      return;
    }
    final value = double.tryParse(
      raw,
    );
    if (value ==
        null) {
      setState(
        () {
          _outputController.text = '';
          _summary = '';
        },
      );
      return;
    }
    String resultText;
    if (widget.group.isTemperature) {
      final fromTemp = _fromUnit.temperatureUnit;
      final toTemp = _toUnit.temperatureUnit;
      if (fromTemp ==
              null ||
          toTemp ==
              null) {
        return;
      }
      resultText = widget.controller.convertTemperature(
        value,
        fromTemp,
        toTemp,
      );
    } else {
      final baseValue =
          value /
          _fromUnit.factor;
      final result =
          baseValue *
          _toUnit.factor;
      resultText = widget.controller.formatResult(
        result,
      );
    }
    setState(
      () {
        _outputController.text = resultText;
        _summary = '$value ${_fromUnit.name} = $resultText ${_toUnit.name}';
      },
    );
  }

  void _swapUnits() {
    setState(
      () {
        final temp = _fromUnit;
        _fromUnit = _toUnit;
        _toUnit = temp;
      },
    );
    _performConversion();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    final isTablet = widget.isTablet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: isTablet
              ? 16
              : 12,
          runSpacing: isTablet
              ? 16
              : 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: isTablet
                  ? 260
                  : MediaQuery.of(
                      context,
                    ).size.width,
              child: TextField(
                controller: _inputController,
                keyboardType: TextInputType.number,
                onChanged:
                    (
                      _,
                    ) => _performConversion(),
                decoration: const InputDecoration(
                  labelText: '输入值',
                  hintText: '请输入数值',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: isTablet
                  ? 220
                  : MediaQuery.of(
                      context,
                    ).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '来源单位',
                        border: OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child:
                            DropdownButton<
                              UnitItem
                            >(
                              value: _fromUnit,
                              isExpanded: true,
                              items: widget.group.units
                                  .map(
                                    (
                                      u,
                                    ) =>
                                        DropdownMenuItem<
                                          UnitItem
                                        >(
                                          value: u,
                                          child: Text(
                                            u.name,
                                          ),
                                        ),
                                  )
                                  .toList(),
                              onChanged:
                                  (
                                    v,
                                  ) {
                                    if (v ==
                                        null) {
                                      return;
                                    }
                                    setState(
                                      () {
                                        _fromUnit = v;
                                      },
                                    );
                                    _performConversion();
                                  },
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                    onPressed: _swapUnits,
                    icon: Icon(
                      Icons.swap_horiz,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: isTablet
                  ? 220
                  : MediaQuery.of(
                      context,
                    ).size.width,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '目标单位',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child:
                      DropdownButton<
                        UnitItem
                      >(
                        value: _toUnit,
                        isExpanded: true,
                        items: widget.group.units
                            .map(
                              (
                                u,
                              ) =>
                                  DropdownMenuItem<
                                    UnitItem
                                  >(
                                    value: u,
                                    child: Text(
                                      u.name,
                                    ),
                                  ),
                            )
                            .toList(),
                        onChanged:
                            (
                              v,
                            ) {
                              if (v ==
                                  null) {
                                return;
                              }
                              setState(
                                () {
                                  _toUnit = v;
                                },
                              );
                              _performConversion();
                            },
                      ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          width: isTablet
              ? 260
              : MediaQuery.of(
                  context,
                ).size.width,
          child: TextField(
            controller: _outputController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '转换结果',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        if (_summary.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                12,
              ),
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.dividerColor.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
            child: Text(
              _summary,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }
}
