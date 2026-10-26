import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/history_entry.dart';

/// Full-screen history panel with glassmorphic design.
class HistoryPanel extends StatelessWidget {
  final List<HistoryEntry> history;
  final VoidCallback onClear;
  final Function(HistoryEntry) onEntryTap;
  final VoidCallback onClose;

  const HistoryPanel({
    super.key,
    required this.history,
    required this.onClear,
    required this.onEntryTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: history.isEmpty ? _buildEmptyState() : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppTheme.textSecondary,
              size: 22,
            ),
            onPressed: onClose,
          ),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              'History',
              style: AppTheme.displayMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: history.isEmpty ? null : onClear,
            child: Text(
              'Clear',
              style: AppTheme.functionText.copyWith(
                color: history.isEmpty
                    ? AppTheme.textDim
                    : AppTheme.deleteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppTheme.textDim.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: AppTheme.expressionStyle.copyWith(color: AppTheme.textDim),
          ),
          const SizedBox(height: 8),
          Text('Your history will appear here', style: AppTheme.historyStyle),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        return _HistoryTile(
          entry: entry,
          onTap: () => onEntryTap(entry),
          index: index,
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  final int index;

  const _HistoryTile({
    required this.entry,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.bgElevated.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.expression,
                style: AppTheme.historyStyle.copyWith(fontSize: 15),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  '= ${entry.result}',
                  style: AppTheme.expressionStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
