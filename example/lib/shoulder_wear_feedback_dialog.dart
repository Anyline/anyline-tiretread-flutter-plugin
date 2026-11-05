import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/material.dart';

/// The value the user picks for one shoulder. [none] sends `null`.
enum _Choice { worn, notWorn, none }

/// Lets the user correct the shoulder wear results (BETA).
///
/// Both sides start from the estimates in the result, so a side the user does
/// not touch is sent as it was reported (the full state the user sees).
class ShoulderWearFeedbackDialog extends StatefulWidget {
  const ShoulderWearFeedbackDialog({
    super.key,
    required this.initialLeft,
    required this.initialRight,
    required this.onCancel,
    required this.onDone,
  });

  final ShoulderWear? initialLeft;
  final ShoulderWear? initialRight;
  final VoidCallback onCancel;
  final void Function(ShoulderWear? left, ShoulderWear? right) onDone;

  @override
  State<ShoulderWearFeedbackDialog> createState() =>
      _ShoulderWearFeedbackDialogState();
}

class _ShoulderWearFeedbackDialogState
    extends State<ShoulderWearFeedbackDialog> {
  late _Choice _left = _fromShoulderWear(widget.initialLeft);
  late _Choice _right = _fromShoulderWear(widget.initialRight);

  static _Choice _fromShoulderWear(ShoulderWear? shoulderWear) {
    if (shoulderWear == null) return _Choice.none;
    return shoulderWear.isWorn ? _Choice.worn : _Choice.notWorn;
  }

  static ShoulderWear? _toShoulderWear(_Choice choice) {
    switch (choice) {
      case _Choice.worn:
        return ShoulderWear(isWorn: true);
      case _Choice.notWorn:
        return ShoulderWear(isWorn: false);
      case _Choice.none:
        return null;
    }
  }

  Widget _side(String label, _Choice value, ValueChanged<_Choice> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.ds.fg2)),
        const SizedBox(height: 6),
        SegmentedButton<_Choice>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: _Choice.worn, label: Text('Worn')),
            ButtonSegment(value: _Choice.notWorn, label: Text('Not worn')),
            ButtonSegment(value: _Choice.none, label: Text('Unknown')),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.single),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.ds.brand;
    final noSide = _left == _Choice.none && _right == _Choice.none;

    return Padding(
      padding: const EdgeInsets.all(16).copyWith(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Shoulder wear feedback (BETA)',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: accent)),
          sizedBox,
          _side('Left shoulder', _left, (v) => setState(() => _left = v)),
          sizedBox,
          _side('Right shoulder', _right, (v) => setState(() => _right = v)),
          if (noSide) ...[
            sizedBox,
            Text('Pick Worn or Not worn for at least one side.',
                style: TextStyle(fontSize: 12, color: context.ds.fg3)),
          ],
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
                // Sending with no side is allowed on purpose, so the example
                // also shows the INVALID_ARGUMENT error from the SDK.
                onPressed: () =>
                    widget.onDone(_toShoulderWear(_left), _toShoulderWear(_right)),
                child: const Text(AppStrings.btnSend),
              ),
            ],
          )
        ],
      ),
    );
  }
}
