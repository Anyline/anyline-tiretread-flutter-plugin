import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/material.dart';

class ExperimentalFlagsDialog extends StatefulWidget {
  const ExperimentalFlagsDialog({
    super.key,
    required this.onCancel,
    required this.onClearFlags,
    required this.onDone,
    required this.selectedFlags,
  });

  final VoidCallback onCancel;
  final VoidCallback onClearFlags;
  final List<String> selectedFlags;

  final void Function(List<String>) onDone;

  @override
  State<ExperimentalFlagsDialog> createState() =>
      _ExperimentalFlagsDialogState();
}

class _ExperimentalFlagsDialogState extends State<ExperimentalFlagsDialog> {
  List<String> selectedFlags = [];
  List<String> flags = [
    ExperimentalFlags.ExperimentalContinuousPictureFocusMode
  ];

  @override
  void initState() {
    selectedFlags.addAll(widget.selectedFlags);
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
            AppStrings.titleExperimentalFlagsDialog,
            style: TextStyle(fontSize: 16, color: Color(0xFF0099FF)),
          ),
          sizedBox,
          ListView.builder(
            shrinkWrap: true,
            itemCount: flags.length,
            itemBuilder: (context, index) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: selectedFlags.contains(flags[index]),
              onChanged: (value) {
                setState(() {
                  if (selectedFlags.contains(flags[index])) {
                    selectedFlags.remove(flags[index]);
                  } else {
                    selectedFlags.add(flags[index]);
                  }
                });
              },
              title: Text(
                (flags[index]),
                style: const TextStyle(
                    color: Color(0xFF000000), fontSize: 14),
              ),
            ),
          ),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0099FF),
                ),
                onPressed: () {
                  widget.onClearFlags();
                },
                child: const Text(AppStrings.btnClearFlags),
              ),
              Row(
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
                    onPressed: (selectedFlags.isNotEmpty)
                        ? () async {
                            widget.onDone(selectedFlags);
                          }
                        : null,
                    child: const Text(AppStrings.btnSet),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
