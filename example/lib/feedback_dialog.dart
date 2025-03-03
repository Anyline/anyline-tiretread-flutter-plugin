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
    // select the entire field on focus for more convenient input
    _feedbackTextController.selection = TextSelection(
        baseOffset: 0, extentOffset: _feedbackTextController.text.length);

    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter Your Comment:',
            style: TextStyle(fontSize: 16, color: Color(0xFF0099FF)),
          ),
          sizedBox,
          TextField(
            controller: _feedbackTextController,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0099FF), width: 1.0),
              ),
            ),
          ),
          sizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0099FF),
                ),
                onPressed: () {
                  _feedbackTextController.text = '';
                  widget.onCancel();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0099FF),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  widget.onDone(_feedbackTextController.text);
                },
                child: const Text('Send'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
