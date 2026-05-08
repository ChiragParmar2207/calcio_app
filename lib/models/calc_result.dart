/// Result type for calculator evaluation.
/// Replaces stringly-typed error handling with a proper sealed class.
sealed class CalcResult {
  const CalcResult();

  bool get isSuccess => this is CalcSuccess;
  bool get isError => this is CalcError;

  /// Get the display string for this result.
  String get displayValue => switch (this) {
    CalcSuccess(value: final v) => v,
    CalcError(message: final m) => m,
  };
}

class CalcSuccess extends CalcResult {
  final String value;
  const CalcSuccess(this.value);
}

class CalcError extends CalcResult {
  final String message;
  const CalcError(this.message);
}
