import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/haptic_settings.dart';
import '../theme/app_theme.dart';
import 'animated_result.dart';

/// Premium display with rich expression highlighting, animated digit result,
/// swipe-to-clear gesture, long-press to copy/share.
class CalcDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final String? lastExpression;
  final bool isScientificMode;
  final bool isErrorResult;
  final VoidCallback onHistoryTap;
  final VoidCallback onModeTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final String? memory;

  const CalcDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.lastExpression,
    required this.isScientificMode,
    this.isErrorResult = false,
    required this.onHistoryTap,
    required this.onModeTap,
    required this.onSettingsTap,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.memory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < -200) {
          onSwipeLeft(); // Clear calculation
        } else if (details.velocity.pixelsPerSecond.dx > 200) {
          onSwipeRight(); // Clear all
        }
      },
      onLongPress: () {
        final text = result.isEmpty ? '0' : result;
        final expr = lastExpression ?? '';
        _showCopyShareSheet(context, text, expr);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Top bar
            _buildTopBar(),
            const Spacer(),
            // Memory indicator
            if (memory != null && memory!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'M: $memory',
                  style: AppTheme.historyStyle.copyWith(
                    color: AppTheme.warningColor,
                    fontSize: 12,
                  ),
                ),
              ),
            // Last expression
            if (lastExpression != null && lastExpression!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  lastExpression!,
                  style: AppTheme.historyStyle.copyWith(fontSize: 15),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Current expression with syntax highlighting
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: _buildHighlightedExpression(),
              ),
            ),
            // Animated result with digit roller
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: AnimatedResultDisplay(
                value: result.isEmpty ? '0' : result,
                fontSize: 52,
                useGradient: result.isNotEmpty && result != '0' && !isErrorResult,
                isError: isErrorResult,
              ),
            ),
            const SizedBox(height: 4),
            // Swipe hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_rounded, size: 12,
                    color: AppTheme.textDim.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  'Swipe to clear • Hold to copy',
                  style: AppTheme.historyStyle.copyWith(
                    fontSize: 10,
                    color: AppTheme.textDim.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Highlight operators, functions, and parens in the expression with colors.
  Widget _buildHighlightedExpression() {
    if (expression.isEmpty) {
      return const SizedBox.shrink();
    }

    final spans = <TextSpan>[];
    final operators = {'+', '−', '×', '÷', '^'};
    final funcNames = {'sin', 'cos', 'tan', 'log', 'ln', 'sqrt', 'abs'};

    int i = 0;
    while (i < expression.length) {
      final char = expression[i];

      // Check for function names
      bool matchedFunc = false;
      for (final fn in funcNames) {
        if (expression.substring(i).startsWith(fn)) {
          spans.add(TextSpan(
            text: fn,
            style: AppTheme.expressionStyle.copyWith(
              color: AppTheme.functionColor,
              fontWeight: FontWeight.w600,
            ),
          ));
          i += fn.length;
          matchedFunc = true;
          break;
        }
      }
      if (matchedFunc) continue;

      // Operators
      if (operators.contains(char)) {
        spans.add(TextSpan(
          text: ' $char ',
          style: AppTheme.expressionStyle.copyWith(
            color: AppTheme.operatorColor,
            fontWeight: FontWeight.w700,
          ),
        ));
      }
      // Parentheses
      else if (char == '(' || char == ')') {
        spans.add(TextSpan(
          text: char,
          style: AppTheme.expressionStyle.copyWith(
            color: AppTheme.accentEnd,
            fontWeight: FontWeight.w600,
          ),
        ));
      }
      // Constants
      else if (char == 'π' || char == 'e') {
        spans.add(TextSpan(
          text: char,
          style: AppTheme.expressionStyle.copyWith(
            color: AppTheme.warningColor,
            fontWeight: FontWeight.w600,
          ),
        ));
      }
      // Regular characters (numbers, dots)
      else {
        spans.add(TextSpan(
          text: char,
          style: AppTheme.expressionStyle,
        ));
      }
      i++;
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Scientific mode toggle
        GestureDetector(
          onTap: onModeTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: isScientificMode ? AppTheme.primaryGradient : null,
              color: isScientificMode ? null : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isScientificMode
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.06),
              ),
              boxShadow: isScientificMode
                  ? [
                      BoxShadow(
                        color: AppTheme.accentStart.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isScientificMode
                      ? Icons.science_rounded
                      : Icons.calculate_rounded,
                  size: 16,
                  color: isScientificMode ? Colors.white : AppTheme.textDim,
                ),
                const SizedBox(width: 6),
                Text(
                  isScientificMode ? 'SCIENTIFIC' : 'STANDARD',
                  style: AppTheme.labelStyle.copyWith(
                    color: isScientificMode ? Colors.white : AppTheme.textDim,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        // History button
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onSettingsTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onHistoryTap,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Error detection is now handled by isErrorResult flag from CalcResult

  void _showCopyShareSheet(BuildContext context, String text, String expr) {
    HapticSettings.medium(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textDim, borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(text, style: AppTheme.displayMedium.copyWith(fontSize: 28)),
            if (expr.isNotEmpty)
              Text(expr, style: AppTheme.historyStyle.copyWith(fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: text));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied!',
                            style: AppTheme.historyStyle.copyWith(color: Colors.white)),
                        backgroundColor: AppTheme.bgElevated,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _actionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () {
                    final shareText = expr.isNotEmpty ? '$expr $text' : text;
                    // ignore: deprecated_member_use
                    Share.share(shareText);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppTheme.accentStart),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.buttonTextSmall.copyWith(
              color: AppTheme.accentStart,
              fontSize: 14,
            )),
          ],
        ),
      ),
    );
  }
}
