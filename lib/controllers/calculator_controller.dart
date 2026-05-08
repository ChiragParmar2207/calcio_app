import 'package:flutter/foundation.dart';
import '../engine/calc_engine.dart';
import '../models/calc_result.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';

/// Extracted business logic controller for the calculator.
/// Owns all state (expression, result, memory, history) and input handlers.
/// The UI screen listens via [ChangeNotifier] and just renders.
class CalculatorController extends ChangeNotifier {
  final CalcEngine _engine = CalcEngine();
  final StorageService storage;

  // ── State ────────────────────────────────────────────────────────────
  String _expression = '';
  String _result = '0';
  String _lastExpression = '';
  bool _isScientificMode = false;
  bool _showHistory = false;
  bool _justEvaluated = false;
  double? _memory;

  CalculatorController({required this.storage}) {
    _loadPersistedState();
  }

  // ── Getters ──────────────────────────────────────────────────────────
  String get expression => _expression;
  String get result => _result;
  String get lastExpression => _lastExpression;
  bool get isScientificMode => _isScientificMode;
  bool get showHistory => _showHistory;
  bool get justEvaluated => _justEvaluated;
  double? get memory => _memory;
  List<HistoryEntry> get history => _engine.history;

  String? get memoryDisplay {
    if (_memory == null) return null;
    return _memory == _memory!.roundToDouble()
        ? _memory!.toInt().toString()
        : _memory!.toStringAsFixed(4);
  }

  // ── Lifecycle ────────────────────────────────────────────────────────

  void _loadPersistedState() {
    _engine.loadHistory(storage.loadHistory());
    _memory = storage.loadMemory();
    _isScientificMode = storage.scientificDefault;
    _expression = '';
    _result = '0';
    _lastExpression = '';
    _justEvaluated = false;
  }

  void _persist() {
    storage.saveHistory(_engine.history);
    storage.saveMemory(_memory);
    storage.saveLastCalc(_lastExpression, _result);
  }

  // ── Unicode operators set ────────────────────────────────────────────
  // Uses both ASCII and Unicode variants to handle operator replacement
  static const _operatorChars = {'+', '-', '−', '×', '÷'};

  // ── Input handlers ────────────────────────────────────────────────────

  void onNumberPressed(String value) {
    if (_justEvaluated) {
      _expression = value;
      _result = value;
      _justEvaluated = false;
    } else {
      _expression += value;
      _liveEvaluate();
    }
    notifyListeners();
  }

  void onOperatorPressed(String op) {
    if (_justEvaluated) {
      _expression = _result + op;
      _justEvaluated = false;
    } else if (_expression.isNotEmpty) {
      final lastChar = _expression[_expression.length - 1];
      if (_operatorChars.contains(lastChar)) {
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
    }
    notifyListeners();
  }

  void onFunctionPressed(String func) {
    if (_justEvaluated) {
      _expression = '$func($_result';
      _justEvaluated = false;
    } else {
      _expression += '$func(';
    }
    notifyListeners();
  }

  void onDecimalPressed() {
    if (_justEvaluated) {
      _expression = '0.';
      _result = '0.';
      _justEvaluated = false;
    } else {
      final parts = _expression.split(RegExp(r'[+\-−×÷]'));
      final currentNumber = parts.isNotEmpty ? parts.last : '';
      if (!currentNumber.contains('.')) {
        _expression +=
            _expression.isEmpty ||
                '+-−×÷('.contains(_expression[_expression.length - 1])
            ? '0.'
            : '.';
      }
    }
    notifyListeners();
  }

  void onParenthesisPressed() {
    if (_justEvaluated) {
      _expression = '(';
      _justEvaluated = false;
      notifyListeners();
      return;
    }

    int openCount = '('.allMatches(_expression).length;
    int closeCount = ')'.allMatches(_expression).length;

    if (_expression.isEmpty ||
        '(+-−×÷'.contains(_expression[_expression.length - 1])) {
      _expression += '(';
    } else if (openCount > closeCount) {
      _expression += ')';
      _liveEvaluate();
    } else {
      _expression += '×(';
    }
    notifyListeners();
  }

  void onPercentPressed() {
    if (_expression.isNotEmpty) {
      _expression += '%';
      _liveEvaluate();
      notifyListeners();
    }
  }

  /// Returns true if evaluation succeeded (triggers particle burst).
  bool onEqualsPressed() {
    if (_expression.isEmpty) return false;

    // Auto-close parentheses
    int openCount = '('.allMatches(_expression).length;
    int closeCount = ')'.allMatches(_expression).length;
    _expression += ')' * (openCount - closeCount);

    final calcResult = _engine.evaluate(_expression);

    _lastExpression = '$_expression =';
    _result = calcResult.displayValue;

    if (calcResult.isSuccess) {
      _engine.addToHistory(_expression, _result);
    }

    _expression = '';
    _justEvaluated = true;
    _persist();
    notifyListeners();
    return true;
  }

  void onClearPressed() {
    _expression = '';
    _result = '0';
    _lastExpression = '';
    _justEvaluated = false;
    notifyListeners();
  }

  void onBackspacePressed() {
    if (_justEvaluated) {
      _expression = '';
      _result = '0';
      _justEvaluated = false;
    } else if (_expression.isNotEmpty) {
      final funcPattern = RegExp(r'(sin|cos|tan|log|ln|sqrt|abs)\($');
      final match = funcPattern.firstMatch(_expression);
      if (match != null) {
        _expression = _expression.substring(
          0,
          _expression.length - match[0]!.length,
        );
      } else {
        _expression = _expression.substring(0, _expression.length - 1);
      }
      _liveEvaluate();
    }
    notifyListeners();
  }

  void onBackspaceLongPress() {
    onClearPressed();
  }

  void appendToExpression(String text) {
    if (_justEvaluated) {
      _expression = text;
      _justEvaluated = false;
    } else {
      _expression += text;
    }
    _liveEvaluate();
    notifyListeners();
  }

  void setExpressionFromResult(String prefix, String suffix) {
    if (_justEvaluated && _result != '0') {
      _expression = '$prefix$_result$suffix';
      _justEvaluated = false;
      _liveEvaluate();
      notifyListeners();
    }
  }

  // ── Live evaluation ──────────────────────────────────────────────────

  void _liveEvaluate() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }

    String expr = _expression;
    int openCount = '('.allMatches(expr).length;
    int closeCount = ')'.allMatches(expr).length;
    expr += ')' * (openCount - closeCount);
    expr = expr.replaceAll(RegExp(r'[+\-−×÷]$'), '');

    if (expr.isNotEmpty) {
      final calcResult = _engine.evaluate(expr);
      if (calcResult is CalcSuccess) {
        _result = calcResult.value;
      }
      // On error, keep previous result — no update
    }
  }

  // ── Memory ────────────────────────────────────────────────────────────

  void onMemoryAdd() {
    final value = double.tryParse(_result);
    if (value != null) {
      _memory = (_memory ?? 0) + value;
      storage.saveMemory(_memory);
      notifyListeners();
    }
  }

  void onMemorySubtract() {
    final value = double.tryParse(_result);
    if (value != null) {
      _memory = (_memory ?? 0) - value;
      storage.saveMemory(_memory);
      notifyListeners();
    }
  }

  void onMemoryRecall() {
    if (_memory != null) {
      final memStr = _memory == _memory!.roundToDouble()
          ? _memory!.toInt().toString()
          : _memory.toString();
      if (_justEvaluated) {
        _expression = memStr;
        _result = memStr;
        _justEvaluated = false;
      } else {
        _expression += memStr;
        _liveEvaluate();
      }
      notifyListeners();
    }
  }

  void onMemoryClear() {
    _memory = null;
    storage.saveMemory(null);
    notifyListeners();
  }

  // ── Mode toggles ─────────────────────────────────────────────────────

  void toggleScientificMode() {
    _isScientificMode = !_isScientificMode;
    notifyListeners();
  }

  void toggleHistory() {
    _showHistory = !_showHistory;
    notifyListeners();
  }

  void onHistoryEntryTap(HistoryEntry entry) {
    _expression = entry.expression;
    _result = entry.result;
    _showHistory = false;
    _justEvaluated = true;
    notifyListeners();
  }

  void clearAllHistory() {
    _engine.clearHistory();
    storage.saveHistory(_engine.history);
    notifyListeners();
  }
}
