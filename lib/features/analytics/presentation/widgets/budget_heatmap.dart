import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/analytics_entities.dart';

class BudgetHeatmap extends StatelessWidget {
  const BudgetHeatmap({
    required this.statuses,
    this.onDayTap,
    super.key,
  });

  final List<DayStatus> statuses;
  final void Function(DayStatus)? onDayTap;

  static const double _cellSize = 11.0;
  static const double _gap = 2.0;
  static const double _cellStep = _cellSize + _gap;
  static const int _cols = 52;
  static const int _rows = 7;
  static const double _totalWidth = _cols * _cellStep;
  static const double _totalHeight = _rows * _cellStep;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _totalWidth,
        height: _totalHeight,
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(_totalWidth, _totalHeight),
              painter: _HeatmapPainter(statuses: statuses),
            ),
            ...statuses.asMap().entries.map((entry) {
              final idx = entry.key;
              final status = entry.value;
              final col = idx ~/ _rows;
              final row = idx % _rows;

              if (col >= _cols) return const SizedBox.shrink();

              return Positioned(
                left: col * _cellStep,
                top: row * _cellStep,
                width: _cellSize,
                height: _cellSize,
                child: Semantics(
                  label: _semanticLabel(status),
                  child: GestureDetector(
                    onTap: () => onDayTap?.call(status),
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static String _semanticLabel(DayStatus status) {
    final dateStr = DateFormat('dd/MM').format(status.date);
    if (!status.hasPurchase) return '$dateStr — Sem compra';
    final spent = status.totalSpent!.format();
    if (status.budgetGoal == null) return '$dateStr — Gasto: $spent';
    final budget = status.budgetGoal!.format();
    return '$dateStr — Gasto: $spent de $budget (meta)';
  }
}

class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter({required this.statuses});

  final List<DayStatus> statuses;

  static const _cellSize = BudgetHeatmap._cellSize;
  static const _cellStep = BudgetHeatmap._cellStep;
  static const _rows = BudgetHeatmap._rows;
  static const _cols = BudgetHeatmap._cols;

  // No purchase
  static const _colorEmpty = Color(0xFFE8EBE6);
  // Within budget — primary-pale → ink-deep
  static const _colorGreenLight = Color(0xFFE2F6D5);
  static const _colorGreenDark = Color(0xFF054D28);
  // No budget set — primary-neutral
  static const _colorNoBudget = Color(0xFFc5edab);
  // Exceeded — light red → negative-darkest
  static const _colorRedLight = Color(0xFFFFE0E0);
  static const _colorRedDark = Color(0xFFA7000D);

  static const _cellRadius = Radius.circular(2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = false;

    for (int i = 0; i < statuses.length; i++) {
      final col = i ~/ _rows;
      final row = i % _rows;

      if (col >= _cols) break;

      final x = col * _cellStep;
      final y = row * _cellStep;

      final rect = RRect.fromLTRBR(
        x,
        y,
        x + _cellSize,
        y + _cellSize,
        _cellRadius,
      );

      paint.color = _colorFor(statuses[i]);
      canvas.drawRRect(rect, paint);
    }
  }

  Color _colorFor(DayStatus status) {
    if (!status.hasPurchase) return _colorEmpty;

    final spent = status.totalSpent!;
    final budget = status.budgetGoal;

    if (budget == null) return _colorNoBudget;

    if (spent <= budget) {
      final intensity =
          budget.cents > 0 ? (spent.cents / budget.cents).clamp(0.1, 1.0) : 0.5;
      return Color.lerp(_colorGreenLight, _colorGreenDark, intensity)!;
    } else {
      final excess = (spent.cents - budget.cents).toDouble();
      final intensity = budget.cents > 0
          ? (excess / budget.cents).clamp(0.1, 1.0)
          : 1.0;
      return Color.lerp(_colorRedLight, _colorRedDark, intensity)!;
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) => old.statuses != statuses;
}
