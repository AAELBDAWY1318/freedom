import 'package:flutter/material.dart';

class AdaptiveLayout {
  // Breakpoints (can be tuned)
  static const double _tabletBreakpoint = 600.0;
  static const double _largeTabletBreakpoint = 900.0;

  // Absolute content max width to avoid extremely wide layouts
  static const double _absoluteContentMaxWidth = 1200.0;

  // Generic clamp helper
  static double _clamp(double value, double min, double max) =>
      value.clamp(min, max);

  static MediaQueryData _mq(BuildContext context) => MediaQuery.of(context);

  // --- Keep existing public API names the same as your code uses ---

  /// Same-name helper: checks if device is tablet by shortestSide.
  static bool isTablet(BuildContext context) {
    final shortestSide = _mq(context).size.shortestSide;
    return shortestSide >= _tabletBreakpoint;
  }

  /// Same-name helper: checks if device is large tablet.
  static bool isLargeTablet(BuildContext context) {
    final shortestSide = _mq(context).size.shortestSide;
    return shortestSide >= _largeTabletBreakpoint;
  }

  /// Same-name: returns a safe max width for central content.
  /// On mobile returns full width, on tablet/large tablet returns a clamped percentage.
  static double getMaxWidth(BuildContext context) {
    final width = _mq(context).size.width;
    if (isLargeTablet(context)) {
      // up to 80% but not less than 600 and never exceed absolute max
      return _clamp(width * 0.8, 600.0, _absoluteContentMaxWidth);
    } else if (isTablet(context)) {
      // up to 90% but keep a sane min/max for forms/cards
      return _clamp(width * 0.9, 480.0, 900.0);
    } else {
      // phone: use full available width
      return width;
    }
  }

  /// Same-name: adaptive padding with min/max clamping
  static EdgeInsets getPadding(BuildContext context) {
    final width = _mq(context).size.width;
    if (isLargeTablet(context)) {
      final horizontal = _clamp(width * 0.06, 32.0, 96.0);
      final vertical = _clamp(width * 0.03, 16.0, 48.0);
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    } else if (isTablet(context)) {
      final horizontal = _clamp(width * 0.06, 24.0, 64.0);
      final vertical = _clamp(width * 0.03, 12.0, 32.0);
      return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
    } else {
      final all = _clamp(width * 0.05, 12.0, 24.0); // kept similar to your original ratio
      return EdgeInsets.all(all);
    }
  }

  /// Same-name: spacing between elements (clamped)
  static double getSpacing(BuildContext context) {
    final width = _mq(context).size.width;
    if (isLargeTablet(context)) return _clamp(width * 0.02, 16.0, 40.0);
    if (isTablet(context)) return _clamp(width * 0.025, 12.0, 28.0);
    return _clamp(width * 0.04, 8.0, 20.0);
  }

  /// Same-name: logo square size with min/max to avoid huge logos
  static double getLogoSize(BuildContext context) {
    final width = _mq(context).size.width;
    double size;
    if (isLargeTablet(context)) {
      size = width * 0.28;
    } else if (isTablet(context)) {
      size = width * 0.3;
    } else {
      size = width * 0.25;
    }
    return _clamp(size, 64.0, 360.0);
  }

  /// Same-name: logo height with clamped values
  static double getLogoHeight(BuildContext context) {
    final height = _mq(context).size.height;
    double h;
    if (isLargeTablet(context)) {
      h = height * 0.22;
    } else if (isTablet(context)) {
      h = height * 0.2;
    } else {
      h = height * 0.15;
    }
    return _clamp(h, 56.0, 420.0);
  }

  /// Same-name: form width (use inside Center -> ConstrainedBox if desired)
  static double getFormWidth(BuildContext context) {
    final width = _mq(context).size.width;
    if (isLargeTablet(context)) return _clamp(width * 0.6, 420.0, 900.0);
    if (isTablet(context)) return _clamp(width * 0.7, 360.0, 700.0);
    return _clamp(width * 0.95, 280.0, width);
  }

  /// Same-name: button height with clamp
  static double getButtonHeight(BuildContext context) {
    final height = _mq(context).size.height;
    if (isTablet(context)) return _clamp(height * 0.05, 40.0, 70.0);
    return _clamp(height * 0.05, 40.0, 64.0);
  }

  /// Same-name: text field height with clamp
  static double getTextFieldHeight(BuildContext context) {
    final height = _mq(context).size.height;
    if (isTablet(context)) return _clamp(height * 0.06, 48.0, 96.0);
    return _clamp(height * 0.05, 40.0, 72.0);
  }

  /// Same-name: font size scaling.
  /// - baseSize: the design font size (e.g. 14)
  /// - respects system textScaleFactor but caps it so layout doesn't break
  static double getFontSize(BuildContext context, double baseSize) {
    final width = _mq(context).size.width;
    // designWidth depends on your design (choose 375 or 400); original used 400 for mobile baseline
    const double designWidth = 375.0;
    final double rawScale = width / designWidth;

    // keep scale in a sane range to avoid huge fonts
    final double clampedScale = _clamp(rawScale, 0.85, 1.45);

    // respect user accessibility setting but cap it
    final double textScale = _clamp(_mq(context).textScaleFactor, 1.0, 1.3);

    final double finalSize = baseSize * clampedScale * textScale;

    // final clamp to ensure font not smaller/larger than extremes relative to baseSize
    return _clamp(finalSize, baseSize * 0.85, baseSize * 2.0);
  }

  // --- Optional helper you can use anywhere (keeps existing names untouched) ---
  /// Build a centered constrained container for main content.
  /// Usage: AdaptiveLayout.centerConstrained(context, child: ...)
  static Widget centerConstrained(BuildContext context, {required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: getMaxWidth(context),
          minWidth: 0,
        ),
        child: child,
      ),
    );
  }
}