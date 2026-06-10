import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../domain/entities/analytics_entities.dart';

class BudgetHeatmap extends StatelessWidget {
  const BudgetHeatmap({required this.statuses, this.onDayTap, super.key});

  final List<DayStatus> statuses;
  final void Function(DayStatus)? onDayTap;

  static const double _cellSize = 11.0;
  static const double _gap = 2.0;
  static const double _cellStep = _cellSize + _gap;
  static const int _rows = 7;
  static const double _monthLabelHeight = 18.0;
  static const double _gridHeight = _rows * _cellStep;

  static int _daysBetween(DateTime a, DateTime b) {
    return DateTime.utc(
      b.year,
      b.month,
      b.day,
    ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
  }

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) return const SizedBox.shrink();

    final firstDate = statuses.first.date;
    // Grid origin: Sunday of the first date's week (GitHub-style, Sunday on top)
    final gridStart = DateTime(
      firstDate.year,
      firstDate.month,
      firstDate.day - firstDate.weekday % 7,
    );

    int colOf(DateTime d) => _daysBetween(gridStart, d) ~/ 7;
    int rowOf(DateTime d) => d.weekday % 7;

    final cols = colOf(statuses.last.date) + 1;
    final totalWidth = cols * _cellStep;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WeekdayLabels(),
        const SizedBox(width: 4),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Start scrolled at the end so today (rightmost column) is visible
            reverse: true,
            child: SizedBox(
              width: totalWidth,
              height: _monthLabelHeight + _gridHeight,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(totalWidth, _monthLabelHeight + _gridHeight),
                    painter: _HeatmapPainter(
                      statuses: statuses,
                      gridStart: gridStart,
                      cols: cols,
                      today: today,
                    ),
                  ),
                  ...statuses.map((status) {
                    final col = colOf(status.date);
                    final row = rowOf(status.date);

                    return Positioned(
                      left: col * _cellStep,
                      top: _monthLabelHeight + row * _cellStep,
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
          ),
        ),
      ],
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

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels();

  static const _style = TextStyle(color: Color(0xFF868685), fontSize: 9);

  @override
  Widget build(BuildContext context) {
    Widget slot(String label) => SizedBox(
      height: BudgetHeatmap._cellStep,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: _style),
      ),
    );

    // GitHub shows Mon / Wed / Fri (rows 1, 3, 5 with Sunday on top)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: BudgetHeatmap._monthLabelHeight),
        slot(''),
        slot('Seg'),
        slot(''),
        slot('Qua'),
        slot(''),
        slot('Sex'),
        slot(''),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  const _HeatmapPainter({
    required this.statuses,
    required this.gridStart,
    required this.cols,
    required this.today,
  });

  final List<DayStatus> statuses;
  final DateTime gridStart;
  final int cols;
  final DateTime today;

  static const _cellSize = BudgetHeatmap._cellSize;
  static const _cellStep = BudgetHeatmap._cellStep;
  static const _monthLabelHeight = BudgetHeatmap._monthLabelHeight;

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
  // Today outline
  static const _colorToday = Color(0xFF0e0f0c);

  static const _cellRadius = Radius.circular(2);

  static const _monthNames = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintMonthLabels(canvas);
    _paintCells(canvas);
  }

  void _paintMonthLabels(Canvas canvas) {
    const style = TextStyle(color: Color(0xFF868685), fontSize: 9);
    int? lastMonth;
    int lastLabelCol = -3;

    for (int col = 0; col < cols; col++) {
      final colDate = DateTime(
        gridStart.year,
        gridStart.month,
        gridStart.day + col * 7,
      );
      if (lastMonth != null && colDate.month == lastMonth) continue;
      lastMonth = colDate.month;
      // Skip if too close to the previous label (partial first month)
      if (col - lastLabelCol < 3) continue;
      lastLabelCol = col;

      final painter = TextPainter(
        text: TextSpan(text: _monthNames[colDate.month - 1], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(col * _cellStep, 0));
    }
  }

  void _paintCells(Canvas canvas) {
    final paint = Paint()..isAntiAlias = false;
    final todayStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _colorToday;

    for (final status in statuses) {
      final col = BudgetHeatmap._daysBetween(gridStart, status.date) ~/ 7;
      final row = status.date.weekday % 7;

      final x = col * _cellStep;
      final y = _monthLabelHeight + row * _cellStep;

      final rect = RRect.fromLTRBR(
        x,
        y,
        x + _cellSize,
        y + _cellSize,
        _cellRadius,
      );

      paint.color = _colorFor(status);
      canvas.drawRRect(rect, paint);

      final d = status.date;
      if (d.year == today.year &&
          d.month == today.month &&
          d.day == today.day) {
        canvas.drawRRect(rect, todayStroke);
      }
    }
  }

  Color _colorFor(DayStatus status) {
    if (!status.hasPurchase) return _colorEmpty;

    final spent = status.totalSpent!;
    final budget = status.budgetGoal;

    if (budget == null) return _colorNoBudget;

    if (spent <= budget) {
      final intensity = budget.cents > 0
          ? (spent.cents / budget.cents).clamp(0.1, 1.0)
          : 0.5;
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
  bool shouldRepaint(_HeatmapPainter old) =>
      old.statuses != statuses || old.today != today;
}
