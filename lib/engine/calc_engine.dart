import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import '../models/calc_result.dart';
import '../models/history_entry.dart';
import '../utils/number_formatter.dart';

class CalcEngine {
  final GrammarParser _parser = GrammarParser();
  final List<HistoryEntry> _history = [];

  List<HistoryEntry> get history => List.unmodifiable(_history);

  // ── Pre-compiled regex constants ────────────────────────────────────
  static final _percentContextual = RegExp(r'([\d.]+)([+\-*/])([\d.]+)%');
  static final _factorial = RegExp(r'(\d+)!');
  static final _squaredExpr = RegExp(r'(\([^)]+\)|\d+\.?\d*)²');
  static final _cubedExpr = RegExp(r'(\([^)]+\)|\d+\.?\d*)³');
  static final _implicitMul = RegExp(r'(\d)\(');
  static final _eulerE = RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z0-9.])');
  static final _divByZero = RegExp(r'/0(?![0-9.])');
  static final _consecutiveOps = RegExp(r'[+\-×÷^]{3,}');

  /// Load persisted history.
  void loadHistory(List<HistoryEntry> entries) {
    _history.clear();
    _history.addAll(entries);
  }

  /// Evaluate an expression and return a typed [CalcResult].
  CalcResult evaluate(String expression) {
    final validationError = _validate(expression);
    if (validationError != null) return CalcError(validationError);

    try {
      final processed = _preprocess(expression);
      final exp = _parser.parse(processed);
      final result = exp.evaluate(EvaluationType.REAL, ContextModel());

      if (result.isNaN) return const CalcError('Undefined');
      if (result.isInfinite) {
        return CalcSuccess(result > 0 ? '∞' : '-∞');
      }

      return CalcSuccess(NumberFormatter.format(result));
    } on FormatException catch (e) {
      final msg = e.message;
      if (msg.contains('factorial')) {
        return const CalcError('Invalid factorial');
      }
      if (msg.contains('Division by zero')) {
        return const CalcError("Can't divide by zero");
      }
      return const CalcError('Bad format');
    } on RangeError {
      return const CalcError('Overflow');
    } catch (_) {
      return const CalcError('Error');
    }
  }

  /// Add a completed calculation to history.
  void addToHistory(String expression, String result) {
    _history.insert(
      0,
      HistoryEntry(
        expression: expression,
        result: result,
        timestamp: DateTime.now(),
      ),
    );
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }
  }

  void clearHistory() {
    _history.clear();
  }

  // ── Validation ──────────────────────────────────────────────────────

  String? _validate(String expr) {
    if (expr.isEmpty) return 'Empty';

    int depth = 0;
    for (final c in expr.split('')) {
      if (c == '(') depth++;
      if (c == ')') depth--;
      if (depth < 0) return 'Missing opening (';
    }

    if (_consecutiveOps.hasMatch(expr)) return 'Invalid operators';

    return null;
  }

  // ── Preprocessing ───────────────────────────────────────────────────

  String _preprocess(String expr) {
    var result = expr;

    // Replace display operators with math operators
    result = result.replaceAll('×', '*');
    result = result.replaceAll('÷', '/');
    result = result.replaceAll('−', '-');

    // Handle % contextually:
    // "200+10%" → "200+200*10/100" (10% of 200)
    // "50%" → "50/100" (plain percent)
    result = result.replaceAllMapped(
      _percentContextual,
      (m) => '${m[1]}${m[2]}${m[1]}*${m[3]}/100',
    );
    result = result.replaceAll('%', '/100');

    // Factorial n! — must come before constant replacement
    result = result.replaceAllMapped(_factorial, (m) {
      final n = int.parse(m[1]!);
      final f = _computeFactorial(n);
      if (f < 0) throw FormatException('Invalid factorial: $n');
      return '$f';
    });

    // x² and x³ — support both bare numbers and parenthesized groups
    result = result.replaceAllMapped(_squaredExpr, (m) => '(${m[1]})^2');
    result = result.replaceAllMapped(_cubedExpr, (m) => '(${m[1]})^3');

    // Implicit multiplication: 2(3+4) -> 2*(3+4)
    result = result.replaceAllMapped(_implicitMul, (m) => '${m[1]}*(');

    // Constants — word-boundary-aware to avoid corrupting function names
    result = result.replaceAll('π', '${math.pi}');
    result = result.replaceAllMapped(_eulerE, (m) => '${math.e}');

    // √ as sqrt
    result = result.replaceAll('√(', 'sqrt(');
    result = result.replaceAll('√', 'sqrt(');

    // Check for division by zero after preprocessing
    if (_divByZero.hasMatch(result)) {
      throw const FormatException('Division by zero');
    }

    return result;
  }

  /// Compute factorial. Returns -1 for invalid input (negative or > 20).
  static int _computeFactorial(int n) {
    if (n < 0) return -1;
    if (n <= 1) return 1;
    if (n > 20) return -1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}
