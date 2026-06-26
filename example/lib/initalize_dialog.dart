import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/env_info.dart';
import 'package:anyline_tire_tread_plugin_example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InitializeDialog extends StatefulWidget {
  const InitializeDialog(
      {super.key, required this.onCancel, required this.onDone});

  final VoidCallback onCancel;

  final void Function(String licenseKey, String selectedFile) onDone;

  @override
  State<InitializeDialog> createState() => _InitializeDialogState();
}

class _InitializeDialogState extends State<InitializeDialog> {
  final TextEditingController _licenseKeyTextController =
      TextEditingController();

  @override
  void initState() {
    _licenseKeyTextController.text = EnvInfo.runTimeLicenseKey;
    loadAssetFileNames();
    super.initState();
  }

  Future<void> loadAssetFileNames() async {
    // Load asset manifest using the new AssetManifest API
    // (AssetManifest.json was deprecated in Flutter 3.19+)
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    // Only list JSON scan-config files; other bundled assets (e.g. the SVG
    // icons under assets/icons/) are not selectable configs.
    final files = assetManifest
        .listAssets()
        .where((String key) =>
            key.startsWith('assets/') && key.endsWith('.json'))
        .toList()
      ..sort();

    // Insert empty option at the beginning for "no config" selection
    files.insert(0, '');

    setState(() {
      fileNames = files;
      selectedFile = files.first;
    });
  }

  List<String> fileNames = [];
  String? selectedFile;

  @override
  Widget build(BuildContext context) {
    final accent = context.ds.brand;

    // select the entire field on focus for more convenient input
    _licenseKeyTextController.selection = TextSelection(
        baseOffset: 0, extentOffset: _licenseKeyTextController.text.length);

    InputDecoration fieldDecoration() => InputDecoration(
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent, width: 1.5),
          ),
        );

    Widget label(String text) => Text(text,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: accent));

    return Padding(
      padding: const EdgeInsets.all(16).copyWith(bottom: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Initialize SDK',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            sizedBox,
            label('License key'),
            const SizedBox(height: 6),
            TextField(
              controller: _licenseKeyTextController,
              autofocus: true,
              decoration: fieldDecoration(),
            ),
            sizedBox,
            label('Config file'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              hint: const Text('Select a file'),
              value: selectedFile,
              onChanged: (String? newValue) {
                setState(() {
                  selectedFile = newValue;
                });
              },
              decoration: fieldDecoration(),
              items: fileNames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value.isEmpty ? '(Default)' : value.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
            sizedBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: accent),
                  onPressed: () {
                    _licenseKeyTextController.text = '';
                    widget.onCancel();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    widget.onDone(
                        _licenseKeyTextController.text, selectedFile ?? '');
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
