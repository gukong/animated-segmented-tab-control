import 'package:flutter/material.dart';

/// Selection option for [SegmentedTabControl]
@immutable
class SegmentTab {
  const SegmentTab({
    required this.label,
    this.padding,
  });

  /// This text will be displayed on tab.
  final String label;

  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry? padding;
}
