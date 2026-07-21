import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/material.dart';

class TreadDepthResultFeedbackDialog extends StatefulWidget {
  const TreadDepthResultFeedbackDialog({
    super.key,
    required this.onCancel,
    required this.onDone,
    required this.isValueInMm,
  });

  final VoidCallback onCancel;
  final bool isValueInMm;

  final void Function(List<TreadResultRegion>) onDone;

  @override
  State<TreadDepthResultFeedbackDialog> createState() =>
      _TreadDepthResultFeedbackDialogState();
}

class _TreadDepthResultFeedbackDialogState
    extends State<TreadDepthResultFeedbackDialog> {
  final List<TextEditingController> _textController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (final c in _textController) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.ds.brand;
    final unit = widget.isValueInMm ? 'mm' : '/32"';

    return Padding(
      padding: const EdgeInsets.all(16).copyWith(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tread depth feedback ($unit)',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: accent)),
          sizedBox,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              return SizedBox(
                width: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _textController[index],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('R$index · $unit',
                        style: TextStyle(fontSize: 13, color: context.ds.fg2)),
                  ],
                ),
              );
            }),
          ),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: accent),
                onPressed: widget.onCancel,
                child: const Text(AppStrings.btnCancel),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final regions = _textController.map((data) {
                    final value = double.tryParse(data.text) ?? 0.0;
                    final available = data.text.isNotEmpty;
                    return widget.isValueInMm
                        ? TreadResultRegion.initMm(
                            available: available, valueMm: value)
                        : TreadResultRegion.initInch(
                            available: available, valueInch: value / 32);
                  }).toList();
                  widget.onDone(regions);
                },
                child: const Text(AppStrings.btnSend),
              ),
            ],
          )
        ],
      ),
    );
  }
}
