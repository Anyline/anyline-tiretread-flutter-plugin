import 'dart:convert';

import 'package:anyline_tire_tread_plugin_example/env_info.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InitializeDialog extends StatefulWidget {
  const InitializeDialog(
      {super.key, required this.onCancel, required this.onDone});

  final VoidCallback onCancel;

  final void Function(String licenseKey, String selectedFile, int? trieWidth)
      onDone;

  @override
  State<InitializeDialog> createState() => _InitializeDialogState();
}

class _InitializeDialogState extends State<InitializeDialog> {
  final TextEditingController _licenseKeyTextController =
      TextEditingController();

  final TextEditingController _tireWidthTextController =
      TextEditingController();

  @override
  void initState() {
    _licenseKeyTextController.text = EnvInfo.runTimeLicenseKey;
    loadAssetFileNames();

    super.initState();
  }

  Future<void> loadAssetFileNames() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    final files = manifestMap.keys
        .where((String key) => key.startsWith('assets/'))
        .toList();

    setState(() {
      fileNames = files;
      selectedFile = files.first;
    });
  }

  List<String> fileNames = [];
  String? selectedFile;

  @override
  Widget build(BuildContext context) {
    // select the entire field on focus for more convenient input
    _licenseKeyTextController.selection = TextSelection(
        baseOffset: 0, extentOffset: _licenseKeyTextController.text.length);

    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter Your License Key:',
              style: TextStyle(fontSize: 16, color: Color(0xFF0099FF)),
            ),
            sizedBox,
            TextField(
              controller: _licenseKeyTextController,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0099FF), width: 1.0),
                ),
              ),
            ),
            sizedBox,
            const Text(
              'Config file',
              style: TextStyle(fontSize: 16, color: Color(0xFF0099FF)),
            ),
            sizedBox,
            DropdownButtonFormField<String>(
              hint: const Text('Select a file'),
              value: selectedFile,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFile = newValue;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0099FF), width: 1.0),
                ),
              ),
              items: fileNames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value.split('/').last), // Display only the file name
                );
              }).toList(),
            ),
            sizedBox,
            const Text(
              'Tire Width',
              style: TextStyle(fontSize: 16, color: Color(0xFF0099FF)),
            ),
            sizedBox,
            TextField(
              controller: _tireWidthTextController,
              autofocus: true,
              keyboardType: TextInputType.number,
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
                    _licenseKeyTextController.text = '';
                    _tireWidthTextController.text = '';
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
                    widget.onDone(
                        _licenseKeyTextController.text,
                        selectedFile!,
                        (_tireWidthTextController.text.isNotEmpty)
                            ? int.tryParse(_tireWidthTextController.text)
                            : null);
                  },
                  child: const Text('Initialize'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
