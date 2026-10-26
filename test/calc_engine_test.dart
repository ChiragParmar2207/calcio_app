import 'package:flutter_test/flutter_test.dart';
import 'package:calcio/engine/calc_engine.dart';

void main() {
  late CalcEngine engine;

  setUp(() {
    engine = CalcEngine();
  });

  group('CalcEngine Arithmetic', () {
    test('Basic addition', () {
      final res = engine.evaluate('2+3');
      expect(res.isSuccess, isTrue);
      expect(res.displayValue, '5');
    });

    test('Basic subtraction', () {
      final res = engine.evaluate('10−4'); // Note: Using Unicode minus
      expect(res.displayValue, '6');
    });

    test('Basic multiplication', () {
      final res = engine.evaluate('6×7');
      expect(res.displayValue, '42');
    });

    test('Basic division', () {
      final res = engine.evaluate('20÷5');
      expect(res.displayValue, '4');
    });

    test('Decimal precision', () {
      final res = engine.evaluate('0.1+0.2');
      // floating point math might give 0.30000000000000004
      // our formatter should clean it up to 0.3
      expect(res.displayValue, '0.3');
    });
  });

  group('CalcEngine Error Handling', () {
    test('Division by zero returns error', () {
      final res = engine.evaluate('5÷0');
      expect(res.isError, isTrue);
      expect(res.displayValue, "Can't divide by zero");
    });

    test('Division by zero with nested expressions', () {
      final res = engine.evaluate('10÷(5−5)');
      expect(res.isError, isFalse);
      expect(res.displayValue, '∞');
    });

    test('Invalid format', () {
      final res = engine.evaluate('5+×3');
      expect(res.isError, isTrue);
      expect(res.displayValue, 'Bad format');
    });

    test('Missing parenthesis', () {
      final res = engine.evaluate('5+(3×2');
      expect(res.isError, isTrue);
      expect(res.displayValue, 'Bad format');
    });

    test('Empty expression', () {
      final res = engine.evaluate('');
      expect(res.isError, isTrue);
      expect(res.displayValue, 'Empty');
    });
  });

  group('CalcEngine Advanced Features', () {
    test('Contextual Percentage (Addition)', () {
      final res = engine.evaluate('200+10%');
      expect(res.displayValue, '220');
    });

    test('Contextual Percentage (Subtraction)', () {
      final res = engine.evaluate('200−10%');
      expect(res.displayValue, '180');
    });

    test('Plain Percentage', () {
      final res = engine.evaluate('50%');
      expect(res.displayValue, '0.5');
    });

    test('Factorial', () {
      final res = engine.evaluate('5!');
      expect(res.displayValue, '120');
    });

    test('Invalid Factorial', () {
      final res = engine.evaluate('(-5)!');
      expect(res.isError, isTrue);
      expect(res.displayValue, 'Error');
    });

    test('Constants (Pi and e)', () {
      final resPi = engine.evaluate('π');
      expect(resPi.displayValue.startsWith('3.141592'), isTrue);

      final resE = engine.evaluate('e');
      expect(resE.displayValue.startsWith('2.718281'), isTrue);
    });

    test('Square and Cube', () {
      final resSq = engine.evaluate('5²');
      expect(resSq.displayValue, '25');

      final resCb = engine.evaluate('2³');
      expect(resCb.displayValue, '8');
    });
  });
}
