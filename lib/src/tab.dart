import 'package:flutter/material.dart';

/// Selection option for [SegmentedTabControl]
@immutable
class SegmentTab {
  const SegmentTab({
    required this.label,
  });

  /// This text will be displayed on tab.
  final String label;
}
