import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../controllers/calculator_controller.dart';
import '../painters/particle_burst.dart';
import '../services/haptic_settings.dart';
import '../services/storage_service.dart';
import '../widgets/calc_button.dart';
import '../widgets/calc_display.dart';
import '../widgets/history_panel.dart';
import '../widgets/settings_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  final StorageService storage;
  final VoidCallback? onSettingsChanged;

  const CalculatorScreen({
    super.key,
    required this.storage,
    this.onSettingsChanged,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with TickerProviderStateMixin {
  late final CalculatorController _ctrl;

  // Staggered button entrance animation
  late AnimationController _entranceController;

  // Particle burst key for equals
  final GlobalKey<ParticleBurstState> _particleBurstKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ctrl = CalculatorController(storage: widget.storage);
    _ctrl.addListener(_onControllerChanged);
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _ctrl.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Stack(
          children: [
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: _ctrl.showHistory
                                ? const Offset(-0.15, 0)
                                : const Offset(0.15, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: _ctrl.showHistory
                    ? HistoryPanel(
                        key: const ValueKey('history'),
                        history: _ctrl.history,
                        onClear: () => _ctrl.clearAllHistory(),
                        onEntryTap: _ctrl.onHistoryEntryTap,
                        onClose: () => _ctrl.toggleHistory(),
                      )
                    : _buildCalculator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculator() {
    return Column(
      key: const ValueKey('calculator'),
      children: [
        // Display area
        Expanded(
          flex: 3,
          child: CalcDisplay(
            expression: _ctrl.expression,
            result: _ctrl.result,
            lastExpression: _ctrl.lastExpression,
            isScientificMode: _ctrl.isScientificMode,
            onHistoryTap: () => _ctrl.toggleHistory(),
            onModeTap: () {
              _ctrl.toggleScientificMode();
              HapticSettings.light(context);
            },
            onSettingsTap: () =>
                SettingsSheet.show(context, widget.storage, () {
                  setState(() {});
                  widget.onSettingsChanged?.call();
                }),
            onSwipeLeft: () {
              _ctrl.onClearPressed();
              HapticSettings.light(context);
            },
            onSwipeRight: () {
              _ctrl.onClearPressed();
              HapticSettings.light(context);
            },
            memory: _ctrl.memoryDisplay,
          ),
        ),
        // Gradient divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppTheme.accentStart.withValues(alpha: 0.4),
                AppTheme.accentEnd.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Memory row
        _buildMemoryRow(),
        // Scientific rows
        AnimatedCrossFade(
          firstChild: _buildScientificRows(),
          secondChild: const SizedBox(width: double.infinity, height: 0),
          crossFadeState: _ctrl.isScientificMode
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 350),
          sizeCurve: Curves.easeOutCubic,
          firstCurve: Curves.easeOutCubic,
          secondCurve: Curves.easeInCubic,
        ),
        // Button grid
        Expanded(
          flex: _ctrl.isScientificMode ? 4 : 5,
          child: _buildButtonGrid(),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildMemoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          _MemoryButton(
            label: 'MC',
            onTap: () {
              _ctrl.onMemoryClear();
              HapticSettings.light(context);
            },
            hasValue: _ctrl.memory != null,
          ),
          _MemoryButton(
            label: 'MR',
            onTap: () {
              _ctrl.onMemoryRecall();
              HapticSettings.light(context);
            },
            hasValue: _ctrl.memory != null,
          ),
          _MemoryButton(
            label: 'M+',
            onTap: () {
              _ctrl.onMemoryAdd();
              HapticSettings.light(context);
            },
            hasValue: true,
          ),
          _MemoryButton(
            label: 'M−',
            onTap: () {
              _ctrl.onMemorySubtract();
              HapticSettings.light(context);
            },
            hasValue: true,
          ),
        ],
      ),
    );
  }

  Widget _buildScientificRows() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Column(
        children: [
          Row(
            children: [
              CalcButton(
                label: 'sin',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onFunctionPressed('sin'),
              ),
              CalcButton(
                label: 'cos',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onFunctionPressed('cos'),
              ),
              CalcButton(
                label: 'tan',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onFunctionPressed('tan'),
              ),
              CalcButton(
                label: 'log',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onFunctionPressed('log'),
              ),
              CalcButton(
                label: 'ln',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onFunctionPressed('ln'),
              ),
            ],
          ),
          Row(
            children: [
              CalcButton(
                label: 'π',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onNumberPressed('π'),
              ),
              CalcButton(
                label: 'e',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onNumberPressed('e'),
              ),
              CalcButton(
                label: 'x²',
                type: CalcButtonType.function,
                onTap: () => _ctrl.appendToExpression('²'),
              ),
              CalcButton(
                label: 'xʸ',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onOperatorPressed('^'),
              ),
              CalcButton(
                label: '√',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onFunctionPressed('sqrt'),
              ),
            ],
          ),
          Row(
            children: [
              CalcButton(
                label: 'n!',
                type: CalcButtonType.function,
                onTap: () => _ctrl.appendToExpression('!'),
              ),
              CalcButton(
                label: '|x|',
                type: CalcButtonType.function,
                onTap: () => _ctrl.onFunctionPressed('abs'),
              ),
              CalcButton(
                label: '1/x',
                type: CalcButtonType.function,
                onTap: () => _ctrl.setExpressionFromResult('1÷', ''),
              ),
              CalcButton(
                label: 'x³',
                type: CalcButtonType.function,
                onTap: () => _ctrl.appendToExpression('³'),
              ),
              CalcButton(
                label: '10ˣ',
                type: CalcButtonType.function,
                onTap: () {
                  if (_ctrl.justEvaluated) {
                    _ctrl.setExpressionFromResult('10^', '');
                  } else {
                    _ctrl.appendToExpression('10^(');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          return Column(
            children: [
              _buildStaggeredRow(0, [
                CalcButton(
                  label: 'C',
                  type: CalcButtonType.delete,
                  onTap: () {
                    _ctrl.onClearPressed();
                    HapticSettings.light(context);
                  },
                ),
                CalcButton(
                  label: '( )',
                  type: CalcButtonType.function,
                  onTap: () => _ctrl.onParenthesisPressed(),
                ),
                CalcButton(
                  label: '%',
                  type: CalcButtonType.function,
                  onTap: () => _ctrl.onPercentPressed(),
                ),
                CalcButton(
                  label: '÷',
                  type: CalcButtonType.operator,
                  onTap: () => _ctrl.onOperatorPressed('÷'),
                ),
              ]),
              _buildStaggeredRow(1, [
                CalcButton(label: '7', onTap: () => _ctrl.onNumberPressed('7')),
                CalcButton(label: '8', onTap: () => _ctrl.onNumberPressed('8')),
                CalcButton(label: '9', onTap: () => _ctrl.onNumberPressed('9')),
                CalcButton(
                  label: '×',
                  type: CalcButtonType.operator,
                  onTap: () => _ctrl.onOperatorPressed('×'),
                ),
              ]),
              _buildStaggeredRow(2, [
                CalcButton(label: '4', onTap: () => _ctrl.onNumberPressed('4')),
                CalcButton(label: '5', onTap: () => _ctrl.onNumberPressed('5')),
                CalcButton(label: '6', onTap: () => _ctrl.onNumberPressed('6')),
                CalcButton(
                  label: '−',
                  type: CalcButtonType.operator,
                  onTap: () => _ctrl.onOperatorPressed('−'),
                ),
              ]),
              _buildStaggeredRow(3, [
                CalcButton(label: '1', onTap: () => _ctrl.onNumberPressed('1')),
                CalcButton(label: '2', onTap: () => _ctrl.onNumberPressed('2')),
                CalcButton(label: '3', onTap: () => _ctrl.onNumberPressed('3')),
                CalcButton(
                  label: '+',
                  type: CalcButtonType.operator,
                  onTap: () => _ctrl.onOperatorPressed('+'),
                ),
              ]),
              _buildStaggeredRow(4, [
                CalcButton(label: '0', onTap: () => _ctrl.onNumberPressed('0')),
                CalcButton(label: '.', onTap: () => _ctrl.onDecimalPressed()),
                CalcButton(
                  icon: Icons.backspace_outlined,
                  label: '⌫',
                  type: CalcButtonType.delete,
                  onTap: () => _ctrl.onBackspacePressed(),
                  onLongPress: () => _ctrl.onBackspaceLongPress(),
                ),
                // Equals with particle burst wrapper
                Expanded(
                  child: ParticleBurst(
                    key: _particleBurstKey,
                    child: CalcButton(
                      label: '=',
                      type: CalcButtonType.equals,
                      onTap: () {
                        final success = _ctrl.onEqualsPressed();
                        if (success) {
                          _particleBurstKey.currentState?.trigger();
                          HapticSettings.heavy(context);
                        }
                      },
                      flex: 0,
                    ),
                  ),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  /// Wrap a row with a staggered entrance animation.
  Widget _buildStaggeredRow(int rowIndex, List<Widget> children) {
    final interval = Interval(
      (rowIndex * 0.12).clamp(0.0, 0.6),
      ((rowIndex * 0.12) + 0.5).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );

    final animation = _entranceController.drive(
      Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: interval)),
    );

    return Expanded(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - animation.value)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Compact memory button.
class _MemoryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool hasValue;

  const _MemoryButton({
    required this.label,
    required this.onTap,
    required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: hasValue ? onTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: hasValue ? 0.04 : 0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasValue
                  ? AppTheme.warningColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.03),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTheme.labelStyle.copyWith(
                color: hasValue ? AppTheme.warningColor : AppTheme.textDim,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
