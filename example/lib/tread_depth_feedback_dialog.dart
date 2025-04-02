import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppStrings.titleCommentFeedbackDialog,
            style: TextStyle(fontSize: 16, color: Color(0xFF0099FF)),
          ),
          sizedBox,
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                return SizedBox(
                  width: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _textController[index],
                        autofocus: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF0099FF), width: 1.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isValueInMm ? 'Mm' : '/32"',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                );
              })),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0099FF),
                ),
                onPressed: () {
                  widget.onCancel();
                },
                child: const Text(AppStrings.btnCancel),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0099FF),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  List<TreadResultRegion> regions = _textController.map((data) {
                    if (widget.isValueInMm) {
                      return TreadResultRegion.initMm(
                          available: data.text.isNotEmpty,
                          valueMm: double.parse(data.text));
                    } else {
                      return TreadResultRegion.initInch(
                          available: data.text.isNotEmpty,
                          valueInch: double.parse(data.text) / 32);
                    }
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
