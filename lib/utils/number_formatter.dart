/// Shared number formatting utility.
/// Eliminates duplicate _formatResult() implementations across CalcEngine and ConverterScreen.
class NumberFormatter {
  /// Default precision configuration.
  static const int defaultFixedPrecision = 10;
  static const int defaultExponentialDigits = 6;
  static const double intThreshold = 1e15;
  static const double exponentialThreshold = 1e12;
  static const double smallNumberThreshold = 1e-6;

  /// Format a double result to a clean display string.
  ///
  /// [fixedPrecision] controls decimal places for non-exponential display.
  /// [exponentialDigits] controls significant digits for exponential notation.
  static String format(
    double value, {
    int fixedPrecision = defaultFixedPrecision,
    int exponentialDigits = defaultExponentialDigits,
  }) {
    // Whole numbers within safe range → display as int
    if (value == value.roundToDouble() && value.abs() < intThreshold) {
      return value.toInt().toString();
    }

    // Very large or very small → scientific notation
    if (value.abs() >= exponentialThreshold ||
        (value.abs() < smallNumberThreshold && value != 0)) {
      return value.toStringAsExponential(exponentialDigits);
    }

    // Normal decimals → trim trailing zeros
    String str = value.toStringAsFixed(fixedPrecision);
    if (str.contains('.')) {
      str = str.replaceAll(RegExp(r'0+$'), '');
      str = str.replaceAll(RegExp(r'\.$'), '');
    }
    return str;
  }
}
