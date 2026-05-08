import 'dart:convert';

/// A single calculation history entry.
class HistoryEntry {
  final String expression;
  final String result;
  final DateTime timestamp;

  const HistoryEntry({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> map) => HistoryEntry(
    expression: map['expression'] as String,
    result: map['result'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );

  /// Serialize to JSON string for storage.
  String encode() => jsonEncode(toJson());

  /// Deserialize from JSON string.
  factory HistoryEntry.decode(String json) =>
      HistoryEntry.fromJson(jsonDecode(json) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryEntry &&
          expression == other.expression &&
          result == other.result &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(expression, result, timestamp);
}
