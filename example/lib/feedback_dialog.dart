import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/material.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog(
      {super.key, required this.onCancel, required this.onDone});

  final VoidCallback onCancel;

  final void Function(String licenseKey) onDone;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _feedbackTextController = TextEditingController();

  @override
  void initState() {
    _feedbackTextController.text = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.ds.brand;
    _feedbackTextController.selection = TextSelection(
        baseOffset: 0, extentOffset: _feedbackTextController.text.length);

    return Padding(
      padding: const EdgeInsets.all(16).copyWith(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppStrings.titleCommentFeedbackDialog,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: accent)),
          sizedBox,
          TextField(
            controller: _feedbackTextController,
            autofocus: true,
            decoration: InputDecoration(
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
          ),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: accent),
                onPressed: () {
                  _feedbackTextController.text = '';
                  widget.onCancel();
                },
                child: const Text(AppStrings.btnCancel),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  widget.onDone(_feedbackTextController.text);
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
