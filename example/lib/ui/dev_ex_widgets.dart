import 'package:anyline_tire_tread_plugin_example/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Small, reusable building blocks for the redesigned API Explorer.
///
/// These map 1:1 to the classes in the handoff reference HTML
/// (`.group`, `.card`, `.chip`, `.metric`, …). Everything else on the screen
/// is composition of these — there is no theming engine or design-token
/// framework beyond [DevExColors].

/// Numbered group label: `1 · SET UP`. Makes order-of-operations explicit.
class GroupHeader extends StatelessWidget {
  const GroupHeader(this.number, this.title,
      {super.key, this.hint, this.trailing});

  final int number;
  final String title;
  final String? hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.onSurface,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text('$number',
                style: TextStyle(
                    color: scheme.surface,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
                color: context.ds.fg2,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          if (hint != null)
            Text(hint!,
                style: TextStyle(
                    color: context.ds.fg3,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Rounded, hairline-bordered container — the redesign's single surface type.
/// No drop shadow (DS rule: border > shadow).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.titleTrailing,
    this.trailing,
    this.stripe,
    this.accent,
    required this.children,
  });

  final String? title;
  final String? subtitle;

  /// Leading identity glyph (typically an [IconTile]).
  final Widget? leading;

  /// Small widget shown inline next to the title (e.g. an "Optional" chip).
  final Widget? titleTrailing;

  /// Right-aligned header widget (a status chip or a toggle).
  final Widget? trailing;

  /// Optional identity accent stripe across the top of the card.
  final Color? stripe;

  /// Reserved for callers that want the accent for inner content.
  final Color? accent;

  final List<Widget> children;

  bool get _hasHeader =>
      title != null || leading != null || trailing != null || subtitle != null;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stripe != null) Container(height: 3, color: stripe),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_hasHeader)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(title!,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                  if (titleTrailing != null) ...[
                                    const SizedBox(width: 8),
                                    titleTrailing!,
                                  ],
                                ],
                              ),
                            if (subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(subtitle!,
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: ds.fg3)),
                              ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 8),
                        trailing!,
                      ],
                    ],
                  ),
                for (final child in children)
                  Padding(
                    padding: EdgeInsets.only(
                        top: _hasHeader || child != children.first ? 12 : 0),
                    child: child,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft-filled status pill: `Supported`, `Ready`, `Complete`.
class StatusChip extends StatelessWidget {
  const StatusChip(this.text, this.color, {super.key, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// An outlined neutral pill — `Optional`.
class MutedChip extends StatelessWidget {
  const MutedChip(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(text,
          style: TextStyle(
              color: context.ds.fg3,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}

/// A rounded, accent-tinted glyph tile — the scanner identity marker.
class IconTile extends StatelessWidget {
  const IconTile._({required this.child, required this.accent, this.size = 38});

  /// Renders one of the bundled Anyline tire SVGs, recoloured to [accent].
  factory IconTile.svg(String asset, Color accent, {double size = 38}) {
    return IconTile._(
      accent: accent,
      size: size,
      child: SvgPicture.asset(
        asset,
        width: size * 0.62,
        height: size * 0.62,
        colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
      ),
    );
  }

  /// Renders a Material icon, tinted to [accent].
  factory IconTile.material(IconData icon, Color accent, {double size = 38}) {
    return IconTile._(
      accent: accent,
      size: size,
      child: Icon(icon, color: accent, size: size * 0.55),
    );
  }

  final Widget child;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: child,
    );
  }
}

/// A result number tile: a label over a big value with an optional unit.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String? unit;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final accent = ds.brand;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: highlight ? accent.withValues(alpha: 0.12) : ds.inset,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: highlight ? accent : ds.fg3)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: highlight
                          ? accent
                          : Theme.of(context).colorScheme.onSurface)),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(unit!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: highlight ? accent : ds.fg3)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// A read-only monospace block, e.g. a generated correlation UUID.
class MonoInset extends StatelessWidget {
  const MonoInset({super.key, this.tag, required this.value, this.tagColor});

  final String? tag;
  final String value;
  final Color? tagColor;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: ds.inset,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (tag != null) ...[
            Text(tag!,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: tagColor ?? ds.correlation)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'monospace', fontSize: 11, color: ds.fg2)),
          ),
        ],
      ),
    );
  }
}

/// Filled pill action — both scan buttons use the brand colour (handoff §3).
class DevExButton extends StatelessWidget {
  const DevExButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.ds.brand;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: c,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Outlined secondary action — used for `Get Results`.
class DevExOutlineButton extends StatelessWidget {
  const DevExOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.dense = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.ds.brand;
    final enabled = onPressed != null;
    return SizedBox(
      width: dense ? null : double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          padding: EdgeInsets.symmetric(
              vertical: dense ? 10 : 12, horizontal: dense ? 16 : 12),
          side: BorderSide(
              color: enabled ? c : Theme.of(context).dividerColor, width: 1.5),
          textStyle:
              TextStyle(fontSize: dense ? 13 : 14, fontWeight: FontWeight.w700),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Asset paths for the bundled Anyline glyphs.
class DevExIcons {
  static const String sidewall = 'assets/icons/tire_sidewall.svg';
  static const String tread = 'assets/icons/tire_tread.svg';
  static const String logo = 'assets/icons/anyline_logo.svg';
}
