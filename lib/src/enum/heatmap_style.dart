// ignore_for_file: constant_identifier_names

/// The style of the heatmap image.
enum HeatmapStyle {
  /// Colored heatmap
  Colored,

  /// Grayscale heatmap
  GrayScale;

  @override
  String toString() => name;
}
