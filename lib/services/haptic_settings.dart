import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Provides haptic feedback setting to the entire widget tree.
/// Wrap your app or screen with this to control haptics globally.
class HapticSettings extends InheritedWidget {
  final bool enabled;

  const HapticSettings({
    super.key,
    required this.enabled,
    required super.child,
  });

  static bool of(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<HapticSettings>();
    return settings?.enabled ?? true;
  }

  /// Trigger light haptic if enabled.
  static void light(BuildContext context) {
    if (of(context)) HapticFeedback.lightImpact();
  }

  /// Trigger medium haptic if enabled.
  static void medium(BuildContext context) {
    if (of(context)) HapticFeedback.mediumImpact();
  }

  /// Trigger heavy haptic if enabled.
  static void heavy(BuildContext context) {
    if (of(context)) HapticFeedback.heavyImpact();
  }

  @override
  bool updateShouldNotify(HapticSettings oldWidget) =>
      enabled != oldWidget.enabled;
}
