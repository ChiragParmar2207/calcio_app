import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/haptic_settings.dart';
import '../theme/app_theme.dart';
import '../utils/number_formatter.dart';

/// Unit converter with multiple categories and a sleek UI.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  int _selectedCategory = 0;
  int _fromUnit = 0;
  int _toUnit = 1;
  String _inputValue = '1';
  String _outputValue = '';
  bool _isNegative = false;

  // ── Conversion data ─────────────────────────────────────────────────
  static const _categories = [
    _Category(
      name: 'Length',
      icon: Icons.straighten_rounded,
      units: ['Meter', 'Kilometer', 'Centimeter', 'Millimeter', 'Mile', 'Yard', 'Foot', 'Inch'],
      toBase: [1, 1000, 0.01, 0.001, 1609.344, 0.9144, 0.3048, 0.0254],
    ),
    _Category(
      name: 'Weight',
      icon: Icons.fitness_center_rounded,
      units: ['Kilogram', 'Gram', 'Milligram', 'Pound', 'Ounce', 'Ton'],
      toBase: [1, 0.001, 0.000001, 0.453592, 0.0283495, 1000],
    ),
    _Category(
      name: 'Temperature',
      icon: Icons.thermostat_rounded,
      units: ['Celsius', 'Fahrenheit', 'Kelvin'],
      toBase: [1, 1, 1], // Special handling
    ),
    _Category(
      name: 'Speed',
      icon: Icons.speed_rounded,
      units: ['m/s', 'km/h', 'mph', 'knots'],
      toBase: [1, 0.277778, 0.44704, 0.514444],
    ),
    _Category(
      name: 'Area',
      icon: Icons.crop_square_rounded,
      units: ['m²', 'km²', 'cm²', 'Hectare', 'Acre', 'ft²'],
      toBase: [1, 1e6, 0.0001, 10000, 4046.86, 0.092903],
    ),
    _Category(
      name: 'Volume',
      icon: Icons.local_drink_rounded,
      units: ['Liter', 'Milliliter', 'Gallon (US)', 'Quart', 'Cup', 'm³'],
      toBase: [1, 0.001, 3.78541, 0.946353, 0.236588, 1000],
    ),
    _Category(
      name: 'Time',
      icon: Icons.access_time_rounded,
      units: ['Second', 'Minute', 'Hour', 'Day', 'Week', 'Year'],
      toBase: [1, 60, 3600, 86400, 604800, 31536000],
    ),
    _Category(
      name: 'Data',
      icon: Icons.storage_rounded,
      units: ['Byte', 'KB', 'MB', 'GB', 'TB', 'PB'],
      toBase: [1, 1024, 1048576, 1073741824, 1099511627776, 1125899906842624],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _convert();
  }

  void _convert() {
    final cat = _categories[_selectedCategory];
    double? input = double.tryParse(_inputValue);
    if (input == null) {
      _outputValue = '';
      return;
    }

    if (_isNegative) input = -input;

    double result;
    if (cat.name == 'Temperature') {
      result = _convertTemperature(input, _fromUnit, _toUnit);
    } else {
      // Convert from source to base, then from base to target
      double inBase = input * cat.toBase[_fromUnit];
      result = inBase / cat.toBase[_toUnit];
    }

    _outputValue = NumberFormatter.format(
      result,
      fixedPrecision: 8,
      exponentialDigits: 4,
    );
  }

  double _convertTemperature(double value, int from, int to) {
    // 0=Celsius, 1=Fahrenheit, 2=Kelvin
    double celsius;
    switch (from) {
      case 0: celsius = value;
      case 1: celsius = (value - 32) * 5 / 9;
      case 2: celsius = value - 273.15;
      default: celsius = value;
    }
    switch (to) {
      case 0: return celsius;
      case 1: return celsius * 9 / 5 + 32;
      case 2: return celsius + 273.15;
      default: return celsius;
    }
  }

  void _onDigit(String digit) {
    setState(() {
      // Prevent multiple decimal points
      if (digit == '.' && _inputValue.contains('.')) return;
      // Handle '00' input when value is '0'
      if (_inputValue == '0' && (digit == '00' || digit == '0')) return;
      if (_inputValue == '0' && digit != '.') {
        _inputValue = digit;
      } else {
        _inputValue += digit;
      }
      _convert();
    });
  }

  void _onBackspace() {
    setState(() {
      if (_inputValue.length <= 1) {
        _inputValue = '0';
        _isNegative = false;
      } else {
        _inputValue = _inputValue.substring(0, _inputValue.length - 1);
      }
      _convert();
    });
  }

  void _onClear() {
    setState(() {
      _inputValue = '0';
      _isNegative = false;
      _convert();
    });
  }

  void _toggleSign() {
    setState(() {
      _isNegative = !_isNegative;
      _convert();
    });
    HapticSettings.light(context);
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _convert();
    });
    HapticSettings.light(context);
  }

  @override
  Widget build(BuildContext context) {
    final cat = _categories[_selectedCategory];

    return SafeArea(
      bottom: false,
      child: Column(
      children: [
        const SizedBox(height: 8),
        // Category tabs
        _buildCategoryTabs(),
        const SizedBox(height: 16),
        // Conversion display
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // From unit
                _buildUnitCard(
                  value: _inputValue,
                  unitIndex: _fromUnit,
                  units: cat.units,
                  isInput: true,
                  onUnitChanged: (i) => setState(() {
                    _fromUnit = i;
                    _convert();
                  }),
                ),
                // Swap button
                _buildSwapButton(),
                // To unit
                _buildUnitCard(
                  value: _outputValue,
                  unitIndex: _toUnit,
                  units: cat.units,
                  isInput: false,
                  onUnitChanged: (i) => setState(() {
                    _toUnit = i;
                    _convert();
                  }),
                ),
              ],
            ),
          ),
        ),
        // Number pad
        Expanded(
          flex: 4,
          child: _buildNumberPad(),
        ),
        const SizedBox(height: 8),
      ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = index == _selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = index;
                _fromUnit = 0;
                _toUnit = 1;
                _isNegative = false;
                _convert();
              });
              HapticSettings.light(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.bgElevated.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 16,
                    color: isSelected ? Colors.white : AppTheme.textDim),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: AppTheme.historyStyle.copyWith(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnitCard({
    required String value,
    required int unitIndex,
    required List<String> units,
    required bool isInput,
    required ValueChanged<int> onUnitChanged,
  }) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isInput
                ? AppTheme.accentStart.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Unit selector
            GestureDetector(
              onTap: () => _showUnitPicker(units, unitIndex, onUnitChanged),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      units[unitIndex],
                      style: AppTheme.functionText.copyWith(
                        fontSize: 14,
                        color: isInput ? AppTheme.accentStart : AppTheme.functionColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isInput ? AppTheme.accentStart : AppTheme.functionColor,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Value
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  (_isNegative ? '-' : '') + (value.isEmpty ? '0' : value),
                  style: AppTheme.displayLarge.copyWith(
                    fontSize: 36,
                    color: isInput ? AppTheme.textPrimary : null,
                    foreground: !isInput
                        ? (Paint()
                          ..shader = AppTheme.primaryGradient.createShader(
                            const Rect.fromLTWH(0, 0, 300, 50),
                          ))
                        : null,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitPicker(List<String> units, int current, ValueChanged<int> onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textDim,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Select Unit', style: AppTheme.expressionStyle.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 8),
                  ...List.generate(units.length, (i) {
                    final isSelected = i == current;
                    return ListTile(
                      title: Text(
                        units[i],
                        style: AppTheme.buttonTextSmall.copyWith(
                          color: isSelected ? AppTheme.accentStart : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppTheme.accentStart, size: 22)
                          : null,
                      onTap: () {
                        onChanged(i);
                        Navigator.pop(context);
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwapButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: _swapUnits,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentStart.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _ConvPadButton(label: '7', onTap: () => _handlePadTap('7')),
                _ConvPadButton(label: '8', onTap: () => _handlePadTap('8')),
                _ConvPadButton(label: '9', onTap: () => _handlePadTap('9')),
                _ConvPadButton(
                  label: '⌫',
                  onTap: () => _handlePadTap('⌫'),
                  onLongPress: _onClear,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _ConvPadButton(label: '4', onTap: () => _handlePadTap('4')),
                _ConvPadButton(label: '5', onTap: () => _handlePadTap('5')),
                _ConvPadButton(label: '6', onTap: () => _handlePadTap('6')),
                _ConvPadButton(label: 'C', onTap: () => _handlePadTap('C')),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _ConvPadButton(label: '1', onTap: () => _handlePadTap('1')),
                _ConvPadButton(label: '2', onTap: () => _handlePadTap('2')),
                _ConvPadButton(label: '3', onTap: () => _handlePadTap('3')),
                _ConvPadButton(label: '.', onTap: () => _handlePadTap('.')),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _ConvPadButton(
                  label: '±',
                  isSign: true,
                  onTap: _toggleSign,
                ),
                _ConvPadButton(
                  label: '0',
                  flex: 2,
                  onTap: () => _handlePadTap('0'),
                ),
                _ConvPadButton(
                  label: '⇄',
                  isSwap: true,
                  onTap: _swapUnits,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePadTap(String label) {
    HapticSettings.light(context);
    switch (label) {
      case 'C':
        _onClear();
      case '⌫':
        _onBackspace();
      default:
        _onDigit(label);
    }
  }
}

/// Interactive converter pad button with scale animation and glassmorphism.
class _ConvPadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int flex;
  final bool isSwap;
  final bool isSign;

  const _ConvPadButton({
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.flex = 1,
    this.isSwap = false,
    this.isSign = false,
  });

  @override
  State<_ConvPadButton> createState() => _ConvPadButtonState();
}

class _ConvPadButtonState extends State<_ConvPadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isAction => widget.label == 'C' || widget.label == '⌫';

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _pressed = true);
          _controller.forward();
          HapticSettings.light(context);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
          _controller.reverse();
        },
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.all(4),
            decoration: _decoration(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shimmer on press
                if (_pressed)
                  Positioned(
                    top: -15,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Center(child: _content()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration() {
    if (widget.isSwap || widget.isSign) {
      return BoxDecoration(
        gradient: widget.isSign ? AppTheme.coolGradient : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: _pressed
            ? []
            : [
                BoxShadow(
                  color: (widget.isSign ? AppTheme.operatorColor : AppTheme.accentStart).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      );
    }
    if (_isAction) {
      return BoxDecoration(
        color: _pressed
            ? AppTheme.deleteColor.withValues(alpha: 0.12)
            : AppTheme.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.deleteColor.withValues(alpha: _pressed ? 0.35 : 0.15),
        ),
      );
    }
    return BoxDecoration(
      color: _pressed
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      border: Border.all(
        color: Colors.white.withValues(alpha: _pressed ? 0.1 : 0.05),
      ),
    );
  }

  Widget _content() {
    if (widget.label == '⌫') {
      return Icon(Icons.backspace_outlined, size: 20,
          color: AppTheme.deleteColor);
    }
    if (widget.label == '⇄') {
      return const Icon(Icons.swap_vert_rounded, size: 22, color: Colors.white);
    }
    if (widget.label == '±') {
      return Text('±', style: AppTheme.buttonText.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ));
    }
    return Text(
      widget.label,
      style: _isAction
          ? AppTheme.buttonTextSmall.copyWith(color: AppTheme.deleteColor)
          : (widget.isSwap || widget.isSign)
              ? AppTheme.buttonText.copyWith(color: Colors.white)
              : AppTheme.buttonText,
    );
  }
}


class _Category {
  final String name;
  final IconData icon;
  final List<String> units;
  final List<double> toBase;

  const _Category({
    required this.name,
    required this.icon,
    required this.units,
    required this.toBase,
  });
}
