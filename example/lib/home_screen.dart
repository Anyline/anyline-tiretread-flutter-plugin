import 'dart:convert';
import 'dart:math';

import 'package:anyline_tire_tread_plugin/anyline_tire_tread_plugin.dart';
import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:anyline_tire_tread_plugin_example/app_strings.dart';
import 'package:anyline_tire_tread_plugin_example/env_info.dart';
import 'package:anyline_tire_tread_plugin_example/feedback_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/initalize_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/main.dart';
import 'package:anyline_tire_tread_plugin_example/result_screen.dart';
import 'package:anyline_tire_tread_plugin_example/tread_depth_feedback_dialog.dart';
import 'package:anyline_tire_tread_plugin_example/ui/dev_ex_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showLoader = false;

  // ── Device support (TTR SDK) ────────────────────────────────────────────
  bool _supportChecked = false;
  bool _deviceSupported = false;
  bool _checkingSupport = false;

  // ── Tire Sidewall (TSW) state ───────────────────────────────────────────
  bool _sidewallSupported = true;
  bool _sidewallLoading = false;
  String _sidewallStatus = '';
  bool _sidewallStatusIsError = false;
  String _sidewallJson = '';
  Uint8List? _sidewallImage;
  String? _detectedSize;

  // Tire width (mm) parsed from the sidewall scan; pre-fills the Tire Width
  // field of the initialize dialog and the tread scan config.
  int? _detectedTireWidth;

  // ── Correlation ID (optional, shared by both scanners) ──────────────────
  bool _includeCorrelationId = true;
  String _correlationId = '';

  // ── Tire Tread state ────────────────────────────────────────────────────
  String _uuid = '';
  final TextEditingController _uuidController = TextEditingController();
  String _treadOutcome = '';
  bool _treadOutcomeIsError = false;
  TreadDepthResult? _result;

  // Scan-config JSON selected in the Tire Tread card. Empty = SDK defaults.
  String selectedConfig = '';
  List<String> _configFiles = [];

  // Tire width (mm) used by the tread scan. Lives in the Tire Tread card; a
  // sidewall scan auto-fills it (see [_runSidewallScan]), otherwise it stays
  // empty for the user to enter by hand.
  final TextEditingController _tireWidthController = TextEditingController();
  int? tireWidth;
  bool _tireWidthFromSidewall = false;

  // Fetched once; cached so rebuilds don't re-query / flicker the version rows.
  final Future<String?> _sdkVersion = tireTreadPlugin.sdkVersion;
  final Future<String?> _pluginVersion = tireTreadPlugin.pluginVersion;

  final ValueNotifier<InitializationStatus> initializationStatus =
      ValueNotifier(InitializationStatus.pending);

  @override
  void initState() {
    super.initState();
    _correlationId = _uuidV4();
    _checkSidewallSupport();
    _loadConfigFiles();
  }

  Future<void> _loadConfigFiles() async {
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

    // Insert empty option at the beginning for "no config" (SDK defaults).
    files.insert(0, '');

    if (mounted) setState(() => _configFiles = files);
  }

  @override
  void dispose() {
    _uuidController.dispose();
    _tireWidthController.dispose();
    initializationStatus.dispose();
    super.dispose();
  }

  bool get _isInitialized =>
      initializationStatus.value == InitializationStatus.done;

  // ══════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            SvgPicture.asset(DevExIcons.logo,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface, BlendMode.srcIn)),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TireTread API Explorer',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Try every SDK option, end to end',
                      style: TextStyle(fontSize: 11, color: context.ds.fg3)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<InitializationStatus>(
          valueListenable: initializationStatus,
          builder: (context, status, _) {
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    // ── 1 · SET UP ──────────────────────────────────────
                    GroupHeader(1, 'Set up',
                        trailing: _isInitialized
                            ? StatusChip('Complete', context.ds.success,
                                icon: Icons.check_circle)
                            : null),
                    _setupCard(status, context),

                    // ── Correlation ID (shared) ─────────────────────────
                    _correlationCard(context),

                    // ── 2 · SCAN ────────────────────────────────────────
                    const GroupHeader(2, 'Scan',
                        hint: 'Two independent scanners'),
                    _sidewallCard(context),
                    _treadCard(status, context),

                    // ── 3 · RESULTS ─────────────────────────────────────
                    const GroupHeader(3, 'Results',
                        hint: 'From the Tread scan above'),
                    _resultsCard(status, context),
                  ],
                ),
                if (showLoader)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black54,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  1 · SET UP
  // ══════════════════════════════════════════════════════════════════════
  Widget _setupCard(InitializationStatus status, BuildContext context) {
    final ds = context.ds;
    return SectionCard(
      children: [
        _metaRow('TTR SDK version', _sdkVersion),
        _hairline(context),
        // Plugin (wrapper) version — surfaced in the Set-up card header area.
        _metaRow('TTR Flutter Plugin Version', _pluginVersion),
        _hairline(context),
        _setupRow(
          context,
          done: _supportChecked && _deviceSupported,
          title: 'Check device support',
          detail: !_supportChecked
              ? 'Not checked yet'
              : _deviceSupported
                  ? 'Device is supported'
                  : 'Device is not supported',
          detailColor: !_supportChecked
              ? ds.fg3
              : _deviceSupported
                  ? ds.success
                  : Theme.of(context).colorScheme.error,
          button: _SoftButton(
            label: _supportChecked ? 'Re-check' : 'Check',
            busy: _checkingSupport,
            onPressed: _checkingSupport ? null : _checkDeviceSupport,
          ),
        ),
        _hairline(context),
        _setupRow(
          context,
          done: status == InitializationStatus.done,
          title: 'Initialize SDK',
          detail: _initDetail(status),
          detailColor: status == InitializationStatus.fail
              ? Theme.of(context).colorScheme.error
              : status == InitializationStatus.done
                  ? ds.success
                  : ds.fg3,
          button: _SoftButton(
            label: status == InitializationStatus.done ? 'Re-init' : 'Initialize',
            onPressed: status == InitializationStatus.start
                ? null
                : () => _openInitializeDialog(context),
          ),
        ),
      ],
    );
  }

  String _initDetail(InitializationStatus status) {
    switch (status) {
      case InitializationStatus.done:
        return 'Initialized · ready to scan';
      case InitializationStatus.start:
        return 'Initializing…';
      case InitializationStatus.fail:
        return 'Initialization failed';
      case InitializationStatus.pending:
        return 'License key required';
    }
  }

  Widget _metaRow(String label, Future<String?> value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.ds.fg2)),
        ),
        const SizedBox(width: 8),
        FutureBuilder<String?>(
          future: value,
          builder: (context, snap) => MonoBadge(snap.data ?? '…'),
        ),
      ],
    );
  }

  Widget _setupRow(
    BuildContext context, {
    required bool done,
    required String title,
    required String detail,
    required Color detailColor,
    required Widget button,
  }) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? const Color(0xFF00BB8E) : context.ds.inset,
            border: done
                ? null
                : Border.all(color: Theme.of(context).dividerColor),
          ),
          child: done
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(detail,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: detailColor)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        button,
      ],
    );
  }

  Widget _hairline(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor);

  // ══════════════════════════════════════════════════════════════════════
  //  CORRELATION ID
  // ══════════════════════════════════════════════════════════════════════
  Widget _correlationCard(BuildContext context) {
    final ds = context.ds;
    return SectionCard(
      accent: ds.correlation,
      leading: IconTile.material(Icons.link, ds.correlation),
      title: 'Correlation ID',
      titleTrailing: const MutedChip('Optional'),
      subtitle:
          'Links one sidewall + one tread scan as a pair. Applies to both scanners below.',
      trailing: Switch(
        value: _includeCorrelationId,
        onChanged: (v) => setState(() {
          _includeCorrelationId = v;
          if (v && _correlationId.isEmpty) _correlationId = _uuidV4();
        }),
      ),
      children: [
        if (_includeCorrelationId)
          Row(
            children: [
              Expanded(
                child: MonoInset(tag: 'UUID', value: _correlationId),
              ),
              IconButton(
                tooltip: 'Regenerate',
                icon: Icon(Icons.refresh, size: 20, color: ds.correlation),
                onPressed: () =>
                    setState(() => _correlationId = _uuidV4()),
              ),
            ],
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  2 · SCAN — TIRE SIDEWALL
  // ══════════════════════════════════════════════════════════════════════
  Widget _sidewallCard(BuildContext context) {
    final ds = context.ds;
    return SectionCard(
      accent: ds.brand,
      leading: IconTile.svg(DevExIcons.sidewall, ds.brand),
      title: 'Tire Sidewall',
      subtitle: 'Reads tire size markings off the sidewall',
      trailing: _sidewallSupported
          ? StatusChip('Supported', ds.success)
          : StatusChip('Not supported', Theme.of(context).colorScheme.error),
      children: [
        if (_includeCorrelationId) _attachedChip(context),
        DevExButton(
          label: AppStrings.btnScanSidewall,
          icon: Icons.center_focus_strong,
          busy: _sidewallLoading,
          onPressed: _runSidewallScan,
        ),
        if (_sidewallStatus.isNotEmpty)
          _statusLine(
            context,
            _sidewallStatus,
            _sidewallStatusIsError
                ? Theme.of(context).colorScheme.error
                : ds.success,
            _sidewallStatusIsError ? Icons.error_outline : Icons.check,
          ),
        if (_sidewallImage != null || _detectedSize != null)
          _sidewallResultRow(context),
        if (_sidewallJson.isNotEmpty) _jsonDisclosure(context, _sidewallJson),
      ],
    );
  }

  Widget _sidewallResultRow(BuildContext context) {
    final ds = context.ds;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_sidewallImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // The TSW scanner returns a 3:4 (portrait) image; match that ratio
            // so the capture shows in full without cropping or distortion.
            child: SizedBox(
              width: 90,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Image.memory(_sidewallImage!, fit: BoxFit.cover),
              ),
            ),
          ),
        if (_sidewallImage != null) const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DETECTED SIZE',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: ds.fg3)),
              const SizedBox(height: 3),
              Text(_detectedSize ?? '—',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              if (_detectedTireWidth != null) ...[
                const SizedBox(height: 7),
                _handoffChip(context, 'Width $_detectedTireWidth mm sent to Tread'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  2 · SCAN — TIRE TREAD
  // ══════════════════════════════════════════════════════════════════════
  Widget _treadCard(InitializationStatus status, BuildContext context) {
    final ds = context.ds;
    final ready = status == InitializationStatus.done;
    return SectionCard(
      accent: ds.brand,
      leading: IconTile.svg(DevExIcons.tread, ds.brand),
      title: 'Tire Tread',
      subtitle: 'Measures tread depth across the tire',
      trailing: ready
          ? StatusChip('Ready', ds.success)
          : const MutedChip('Init required'),
      children: [
        if (_includeCorrelationId) _attachedChip(context),
        _configField(context),
        _tireWidthField(context),
        DevExButton(
          label: AppStrings.btnScan,
          icon: Icons.crop_free,
          onPressed: ready ? _runTreadScan : null,
        ),
        if (_treadOutcome.isNotEmpty)
          _statusLine(
            context,
            _treadOutcome,
            _treadOutcomeIsError
                ? Theme.of(context).colorScheme.error
                : ds.success,
            _treadOutcomeIsError ? Icons.error_outline : Icons.check,
          ),
        _uuidField(context),
      ],
    );
  }

  /// Scan-config picker for the tread scan. Lists the JSON configs bundled
  /// under assets/; the empty option runs with the SDK defaults. Editable per
  /// scan — the selection is read in [_runTreadScan].
  Widget _configField(BuildContext context) {
    final ds = context.ds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: ds.fg2),
            children: [
              const TextSpan(text: 'Scan config '),
              TextSpan(text: '(JSON)', style: TextStyle(color: ds.fg3)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          // _configFiles is filled asynchronously by _loadConfigFiles; until it
          // is, the dropdown would assert on a value that matches no item, so
          // fall back to null while the list is still empty.
          value: _configFiles.contains(selectedConfig) ? selectedConfig : null,
          isExpanded: true,
          icon: Icon(Icons.tune, size: 16, color: ds.fg3),
          style: TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w600, color: ds.fg2),
          onChanged: (v) => setState(() => selectedConfig = v ?? ''),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: ds.inset,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          items: _configFiles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.isEmpty ? 'Default config' : value.split('/').last,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Tire width (mm) field for the tread scan. A sidewall scan auto-fills this
  /// (with a "from sidewall" tag); it's also editable by hand and starts empty.
  Widget _tireWidthField(BuildContext context) {
    final ds = context.ds;
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: ds.fg2),
              children: [
                const TextSpan(text: 'Tire width '),
                TextSpan(text: '(mm)', style: TextStyle(color: ds.fg3)),
              ],
            ),
          ),
        ),
        if (_tireWidthFromSidewall) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: ds.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text('from sidewall',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: ds.brand)),
          ),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 84,
          child: TextField(
            controller: _tireWidthController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            onChanged: (v) => setState(() {
              tireWidth = int.tryParse(v.trim());
              _tireWidthFromSidewall = false;
            }),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              isDense: true,
              hintText: '—',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: ds.brand, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _uuidField(BuildContext context) {
    final ds = context.ds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MEASUREMENT UUID',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: ds.fg3)),
        const SizedBox(height: 6),
        TextField(
          controller: _uuidController,
          onChanged: (v) => setState(() => _uuid = v.trim()),
          style: TextStyle(
              fontFamily: 'monospace', fontSize: 12, color: ds.fg2),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'set by a scan, or paste one to fetch results',
            hintStyle: TextStyle(fontSize: 11, color: ds.fg3),
            filled: true,
            fillColor: ds.inset,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  3 · RESULTS  (+ feedback)
  // ══════════════════════════════════════════════════════════════════════
  Widget _resultsCard(InitializationStatus status, BuildContext context) {
    final canFetch = status == InitializationStatus.done && _uuid.isNotEmpty;
    return SectionCard(
      children: [
        DevExOutlineButton(
          label: AppStrings.btnGetResult,
          icon: Icons.download_outlined,
          onPressed: canFetch ? _getResults : null,
        ),
        if (_result != null) ..._resultMetrics(context, _result!),
        if (_result != null)
          DevExOutlineButton(
            label: 'Heatmap & full result',
            icon: Icons.image_outlined,
            dense: true,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => ResultScreen(uuid: _uuid)),
            ),
          ),
        if (_result != null) _feedbackSection(context),
      ],
    );
  }

  List<Widget> _resultMetrics(BuildContext context, TreadDepthResult result) {
    final ds = context.ds;
    String mm(TreadResultRegion? r) =>
        r == null ? '—' : r.valueMm.toStringAsFixed(2);
    final regions = result.regions ?? const <TreadResultRegion>[];
    return [
      Row(
        children: [
          Expanded(
              child: MetricTile(
                  label: 'Global', value: mm(result.global), unit: 'mm')),
          const SizedBox(width: 10),
          Expanded(
              child: MetricTile(
                  label: 'Minimum',
                  value: mm(result.minimumValue),
                  unit: 'mm',
                  highlight: true)),
        ],
      ),
      if (regions.isNotEmpty) ...[
        Text('PER REGION',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: ds.fg3)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < regions.length; i++)
              _regionTile(context, 'R$i', mm(regions[i])),
          ],
        ),
      ],
    ];
  }

  Widget _regionTile(BuildContext context, String label, String value) {
    final ds = context.ds;
    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: ds.inset,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: ds.fg3)),
          const SizedBox(height: 3),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _feedbackSection(BuildContext context) {
    final ds = context.ds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Text('FEEDBACK',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: ds.fg3)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DevExOutlineButton(
                label: 'Comment',
                icon: Icons.comment_outlined,
                dense: true,
                onPressed: () => _openCommentFeedback(context)),
            DevExOutlineButton(
                label: 'Values (mm)',
                icon: Icons.straighten,
                dense: true,
                onPressed: () => _openValueFeedback(context, isMm: true)),
            DevExOutlineButton(
                label: 'Values (1/32")',
                icon: Icons.straighten,
                dense: true,
                onPressed: () => _openValueFeedback(context, isMm: false)),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  Shared small pieces
  // ══════════════════════════════════════════════════════════════════════
  Widget _attachedChip(BuildContext context) {
    final ds = context.ds;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: ds.correlation.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link, size: 13, color: ds.correlation),
            const SizedBox(width: 5),
            Text('correlationId attached',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ds.correlation)),
          ],
        ),
      ),
    );
  }

  Widget _handoffChip(BuildContext context, String text) {
    final ds = context.ds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: ds.brand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: ds.brand)),
    );
  }

  Widget _statusLine(
      BuildContext context, String text, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }

  Widget _jsonDisclosure(BuildContext context, String json) {
    final ds = context.ds;
    // The ExpansionTile's header is a ListTile, which paints its ink/ripple on
    // the nearest Material. SectionCard's decorated Container would otherwise
    // hide that, so give the tile its own (transparent) Material ancestor.
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 4),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text('Result JSON',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: ds.fg3)),
          iconColor: ds.fg3,
          collapsedIconColor: ds.fg3,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 260),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: ds.inset,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: SelectableText(json,
                    style: TextStyle(
                        fontFamily: 'monospace', fontSize: 11, color: ds.fg2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  ACTIONS  (SDK calls — unchanged behaviour, just re-homed)
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _checkSidewallSupport() async {
    try {
      final support = await tireSidewallPlugin.isSupported();
      if (mounted) setState(() => _sidewallSupported = support.supported);
    } catch (_) {
      // Leave the optimistic default; a failing scan reports the real reason.
    }
  }

  Future<void> _checkDeviceSupport() async {
    setState(() => _checkingSupport = true);
    try {
      final supported = await tireTreadPlugin.isDeviceSupported();
      if (!mounted) return;
      setState(() {
        _deviceSupported = supported;
        _supportChecked = true;
      });
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _deviceSupported = false;
          _supportChecked = true;
        });
        showSnackBar(context, error.message ?? 'Device support check failed');
      }
    } finally {
      if (mounted) setState(() => _checkingSupport = false);
    }
  }

  void _openInitializeDialog(BuildContext context) {
    EnvInfo.runTimeLicenseKey = EnvInfo.licenseKey ?? '';
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: InitializeDialog(
          onCancel: () => Navigator.pop(context),
          onDone: (licenseKey) async {
            EnvInfo.runTimeLicenseKey = licenseKey;
            Navigator.of(context).pop();
            setState(() {
              _uuid = '';
              _uuidController.text = '';
              _result = null;
              _treadOutcome = '';
            });
            await _startInitialization();
          },
        ),
      ),
    );
  }

  Future<void> _runTreadScan() async {
    try {
      setState(() {
        _uuid = '';
        _uuidController.text = '';
        _result = null;
        _treadOutcome = '';
      });

      TireTreadConfig config = TireTreadConfig();
      if (selectedConfig.isNotEmpty) {
        final data = await rootBundle.loadString(selectedConfig);
        config = TireTreadConfig.fromJson(jsonDecode(data) as Map<String, dynamic>);
      }
      if (tireWidth != null) {
        config.scanConfig.tireWidth = tireWidth;
      }
      if (_includeCorrelationId) {
        config.additionalContext =
            (config.additionalContext ?? AdditionalContext())
              ..correlationId = _correlationId;
      }

      final outcome = await tireTreadPlugin.scan(config: config);
      if (!mounted) return;
      switch (outcome) {
        case ScanCompleted():
          setState(() {
            _uuid = outcome.measurementUUID;
            _uuidController.text = _uuid;
            _treadOutcome = 'Outcome: success';
            _treadOutcomeIsError = false;
          });
        case ScanAborted():
          setState(() {
            _treadOutcome = 'Outcome: aborted';
            _treadOutcomeIsError = false;
          });
        case ScanFailed():
          setState(() {
            _treadOutcome = 'Outcome: failed — ${outcome.error.message}';
            _treadOutcomeIsError = true;
          });
          showSnackBar(context, outcome.error.message);
      }
    } on PlatformException catch (error) {
      if (kDebugMode) print(error);
      if (mounted) {
        setState(() {
          _treadOutcome = 'Outcome: failed — ${error.message}';
          _treadOutcomeIsError = true;
        });
      }
    }
  }

  // Tire Sidewall (TSW) is a separate scanner; it does not require SDK
  // initialization.
  Future<void> _runSidewallScan() async {
    try {
      final support = await tireSidewallPlugin.isSupported();
      if (mounted) setState(() => _sidewallSupported = support.supported);
      if (!support.supported) {
        if (mounted) {
          showSnackBar(context,
              'Sidewall not supported: ${support.error?.message ?? ''}');
        }
        if (support.userResolvable) {
          await tireSidewallPlugin.resolvePlayServices();
        }
        return;
      }

      setState(() {
        _sidewallLoading = true;
        _sidewallStatus = 'Scanning…';
        _sidewallStatusIsError = false;
        _sidewallJson = '';
        _sidewallImage = null;
        _detectedSize = null;
        _detectedTireWidth = null;
      });

      final config = _includeCorrelationId
          ? (TireSidewallConfig()..correlationId = _correlationId)
          : null;
      final outcome = await tireSidewallPlugin.scan(
          clientId: EnvInfo.sidewallClientId, config: config);
      if (!mounted) return;
      setState(() {
        _sidewallLoading = false;
        switch (outcome) {
          case TswScanCompleted():
            _sidewallStatusIsError = false;
            _sidewallImage = outcome.imageBytes;
            _sidewallJson = _prettyJson(outcome.resultJson);
            _detectedSize = _sizeFromResultJson(outcome.resultJson);
            _detectedTireWidth = _tireWidthFromResultJson(outcome.resultJson);
            // Hand the detected width to the Tire Tread card's width field.
            if (_detectedTireWidth != null) {
              tireWidth = _detectedTireWidth;
              _tireWidthController.text = _detectedTireWidth.toString();
              _tireWidthFromSidewall = true;
            }
            _sidewallStatus = 'Completed'
                ' (lighting: ${outcome.lighting?.name ?? 'n/a'}'
                '${_detectedTireWidth != null ? ', tire width: ${_detectedTireWidth}mm' : ''})';
          case TswScanAborted():
            _sidewallStatusIsError = false;
            _sidewallStatus = 'Sidewall scan aborted';
          case TswScanFailed():
            _sidewallStatusIsError = true;
            _sidewallStatus =
                'Failed (${outcome.error.code.name}): ${outcome.error.message}';
        }
      });
    } on PlatformException catch (error) {
      if (kDebugMode) print(error);
      if (mounted) {
        setState(() {
          _sidewallLoading = false;
          _sidewallStatusIsError = true;
          _sidewallStatus = 'Failed: ${error.message}';
        });
      }
    }
  }

  Future<void> _getResults() async {
    setState(() => showLoader = true);
    try {
      final result = await tireTreadPlugin.getResult(measurementUUID: _uuid);
      if (mounted) setState(() => _result = result);
    } on PlatformException catch (error) {
      if (mounted) showSnackBar(context, error.message ?? 'Failed to get result');
    } finally {
      if (mounted) setState(() => showLoader = false);
    }
  }

  void _openCommentFeedback(BuildContext context) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (con) => Dialog(
        child: FeedbackDialog(
          onCancel: () => Navigator.pop(con),
          onDone: (comment) async {
            Navigator.of(con).pop();
            await _runFeedback(() => tireTreadPlugin.sendFeedbackComment(
                measurementUUID: _uuid, comment: comment));
          },
        ),
      ),
    );
  }

  void _openValueFeedback(BuildContext context, {required bool isMm}) {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (con) => Dialog(
        child: TreadDepthResultFeedbackDialog(
          isValueInMm: isMm,
          onCancel: () => Navigator.pop(con),
          onDone: (regions) async {
            Navigator.of(con).pop();
            await _runFeedback(() =>
                tireTreadPlugin.sendTreadDepthResultFeedback(
                    measurementUUID: _uuid, resultRegions: regions));
          },
        ),
      ),
    );
  }

  Future<void> _runFeedback(Future<void> Function() send) async {
    try {
      setState(() => showLoader = true);
      await send();
      if (mounted) showSnackBar(context, AppStrings.messageFeedbackSuccess);
    } on PlatformException catch (error) {
      if (mounted) showSnackBar(context, error.message ?? 'Feedback failed');
    } finally {
      if (mounted) setState(() => showLoader = false);
    }
  }

  Future<void> _startInitialization() async {
    try {
      setState(() {
        _uuid = '';
        showLoader = true;
      });
      initializationStatus.value = InitializationStatus.start;
      await tireTreadPlugin.initialize(EnvInfo.licenseKey ?? '');
      initializationStatus.value = InitializationStatus.done;
    } on PlatformException catch (error) {
      initializationStatus.value = InitializationStatus.fail;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.details as String? ?? 'Init failed')),
        );
      }
    } finally {
      if (mounted) setState(() => showLoader = false);
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Parsing helpers (mirror the original screen) ─────────────────────────
  String _prettyJson(String raw) {
    try {
      return const JsonEncoder.withIndent('  ').convert(jsonDecode(raw));
    } catch (_) {
      return raw;
    }
  }

  String? _sizeFromResultJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final size = decoded['size'];
      return (size is String && size.isNotEmpty) ? size : null;
    } catch (_) {
      return null;
    }
  }

  int? _tireWidthFromResultJson(String raw) {
    final size = _sizeFromResultJson(raw);
    if (size == null) return null;
    return _extractTireWidthFromTireSizeString(size);
  }

  int? _extractTireWidthFromTireSizeString(String tireSizeString) {
    final match = RegExp(r'[A-Za-z]*\d{3}').firstMatch(tireSizeString);
    final digits = match?.group(0)?.replaceAll(RegExp(r'\D'), '');
    if (digits == null || digits.length < 3) return null;
    final width = int.tryParse(digits.substring(0, 3));
    if (width == null || width < 100 || width > 500) return null;
    return width;
  }

  /// Generates a version-4 UUID for the correlation ID. The SDK rejects any
  /// non-v4 value with `ErrorCode.invalidUuid`.
  String _uuidV4() {
    final rnd = Random();
    final b = List<int>.generate(16, (_) => rnd.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String h(int i) => b[i].toRadixString(16).padLeft(2, '0');
    return '${h(0)}${h(1)}${h(2)}${h(3)}-${h(4)}${h(5)}-${h(6)}${h(7)}-'
        '${h(8)}${h(9)}-${h(10)}${h(11)}${h(12)}${h(13)}${h(14)}${h(15)}';
  }
}

/// A compact monospace value badge used by the Set-up meta rows.
class MonoBadge extends StatelessWidget {
  const MonoBadge(this.value, {super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: ds.inset,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(value,
          style:
              TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: ds.fg3)),
    );
  }
}

/// A small soft-filled secondary action used inside the Set-up rows.
class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.label, this.onPressed, this.busy = false});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final enabled = onPressed != null && !busy;
    return Material(
      color: enabled ? ds.brand.withValues(alpha: 0.12) : ds.inset,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: busy ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: busy
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: ds.brand))
              : Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: enabled ? ds.brand : ds.fg3)),
        ),
      ),
    );
  }
}
