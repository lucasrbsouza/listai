import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/analytics_entities.dart';
import '../providers/analytics_provider.dart';
import '../widgets/budget_heatmap.dart';

const _kPrimary = Color(0xFF9fe870);
const _kCanvas = Color(0xFFffffff);
const _kCanvasSoft = Color(0xFFe8ebe6);
const _kInk = Color(0xFF0e0f0c);
const _kBody = Color(0xFF454745);
const _kMute = Color(0xFF868685);
const _kNegative = Color(0xFFd03238);
const _kPositive = Color(0xFF2ead4b);
const _kRadius = Radius.circular(24);

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final analyticsAsync = ref.watch(analyticsDataProvider(period));
    final heatmapAsync = ref.watch(heatmapDataProvider);

    return Scaffold(
      backgroundColor: _kCanvasSoft,
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        backgroundColor: _kCanvas,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kInk),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _PeriodDropdown(
              value: period,
              onChanged: (p) =>
                  ref.read(selectedPeriodProvider.notifier).state = p!,
            ),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _kPrimary)),
        error: (e, _) => Center(
          child: Text(
            'Erro ao carregar dados: $e',
            style: const TextStyle(color: _kNegative),
          ),
        ),
        data: (data) => _AnalyticsBody(
          data: data,
          period: period,
          heatmapStatuses: heatmapAsync.valueOrNull,
        ),
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({required this.value, required this.onChanged});

  final AnalyticsPeriod value;
  final ValueChanged<AnalyticsPeriod?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _kCanvasSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AnalyticsPeriod>(
          value: value,
          style: const TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          dropdownColor: _kCanvas,
          onChanged: onChanged,
          items: const [
            DropdownMenuItem(
              value: AnalyticsPeriod.weekly,
              child: Text('Semanal'),
            ),
            DropdownMenuItem(
              value: AnalyticsPeriod.monthly,
              child: Text('Mensal'),
            ),
            DropdownMenuItem(
              value: AnalyticsPeriod.yearly,
              child: Text('Anual'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({
    required this.data,
    required this.period,
    this.heatmapStatuses,
  });

  final AnalyticsData data;
  final AnalyticsPeriod period;
  final List<DayStatus>? heatmapStatuses;

  @override
  Widget build(BuildContext context) {
    final hasAnyData =
        data.spendingPoints.isNotEmpty ||
        data.topMarkets.isNotEmpty ||
        data.mostBoughtProducts.isNotEmpty;

    if (!hasAnyData) {
      return const Center(child: _EmptyState());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SpendingChartCard(points: data.spendingPoints, period: period),
          const SizedBox(height: 16),
          _BudgetIndicatorCard(result: data.budgetExceededResult),
          const SizedBox(height: 16),
          _HeatmapCard(statuses: heatmapStatuses),
          const SizedBox(height: 16),
          if (data.topMarkets.isNotEmpty) ...[
            _TopMarketsCard(markets: data.topMarkets),
            const SizedBox(height: 16),
          ],
          if (data.mostBoughtProducts.isNotEmpty) ...[
            _ProductListCard(
              title: 'Produtos Mais Comprados',
              icon: Icons.shopping_cart_outlined,
              children: data.mostBoughtProducts
                  .map(
                    (p) => _ProductListTile(
                      name: p.productName,
                      type: p.productType,
                      subtitle:
                          '${p.count} ${p.count == 1 ? 'compra' : 'compras'}',
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (data.topSpendingProducts.isNotEmpty) ...[
            _ProductListCard(
              title: 'Maior Gasto por Produto',
              icon: Icons.attach_money,
              children: data.topSpendingProducts
                  .map(
                    (p) => _ProductListTile(
                      name: p.productName,
                      type: p.productType,
                      subtitle: p.total.format(),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _kCanvas,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.bar_chart_outlined, size: 40, color: _kMute),
        ),
        const SizedBox(height: 16),
        const Text(
          'Nenhum dado disponível',
          style: TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Finalize compras para visualizar\nsuas estatísticas aqui.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _kBody, fontSize: 14),
        ),
      ],
    );
  }
}

class _SpendingChartCard extends StatelessWidget {
  const _SpendingChartCard({required this.points, required this.period});

  final List<SpendingPoint> points;
  final AnalyticsPeriod period;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: 'Gastos no Período', icon: Icons.show_chart),
          const SizedBox(height: 16),
          if (points.isEmpty)
            const _NoDataLabel()
          else
            SizedBox(height: 180, child: _SpendingLineChart(points: points)),
        ],
      ),
    );
  }
}

class _SpendingLineChart extends StatelessWidget {
  const _SpendingLineChart({required this.points});

  final List<SpendingPoint> points;

  @override
  Widget build(BuildContext context) {
    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.total.reais);
    }).toList();

    final maxY = points
        .map((p) => p.total.reais)
        .fold(0.0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: _kCanvasSoft, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: (points.length / 4).ceilToDouble().clamp(
                1,
                double.infinity,
              ),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= points.length) return const SizedBox();
                final date = points[idx].date;
                return Text(
                  DateFormat('d/M').format(date),
                  style: const TextStyle(color: _kMute, fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox();
                return Text(
                  'R\$${value.toInt()}',
                  style: const TextStyle(color: _kMute, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _kPrimary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _kPrimary.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopMarketsCard extends StatelessWidget {
  const _TopMarketsCard({required this.markets});

  final List<MarketSpending> markets;

  @override
  Widget build(BuildContext context) {
    final maxCents = markets
        .map((m) => m.total.cents)
        .fold(0, (a, b) => a > b ? a : b);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(title: 'Top Mercados', icon: Icons.store_outlined),
          const SizedBox(height: 16),
          SizedBox(
            height: (markets.length * 48.0).clamp(100.0, 260.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final m = markets[groupIndex];
                      return BarTooltipItem(
                        '${m.marketName}\n${m.total.format()}',
                        const TextStyle(color: _kInk, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= markets.length) {
                          return const SizedBox();
                        }
                        final name = markets[idx].marketName;
                        final short = name.length > 10
                            ? '${name.substring(0, 10)}…'
                            : name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            short,
                            style: const TextStyle(color: _kBody, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: markets.asMap().entries.map((e) {
                  final ratio = maxCents > 0
                      ? e.value.total.cents / maxCents
                      : 0.0;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.total.reais,
                        color:
                            Color.lerp(
                              _kPrimary,
                              const Color(0xFF2a8c50),
                              ratio,
                            ) ??
                            _kPrimary,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: _kRadius,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetIndicatorCard extends StatelessWidget {
  const _BudgetIndicatorCard({required this.result});

  final BudgetExceededResult result;

  @override
  Widget build(BuildContext context) {
    final total = result.totalPurchases;
    final exceeded = result.exceededCount;
    final color = exceeded > 0 ? _kNegative : _kPositive;

    return _Card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              exceeded > 0
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0
                      ? 'Nenhuma compra no período'
                      : 'Ultrapassou meta $exceeded ${exceeded == 1 ? 'vez' : 'vezes'} em $total ${total == 1 ? 'compra' : 'compras'}',
                  style: const TextStyle(
                    color: _kInk,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: total > 0 ? exceeded / total : 0,
                    backgroundColor: _kCanvasSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  const _ProductListCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(title: title, icon: icon),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({
    required this.name,
    required this.type,
    required this.subtitle,
  });

  final String name;
  final String type;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _kCanvasSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: _kBody,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _kInk,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(type, style: const TextStyle(color: _kMute, fontSize: 12)),
              ],
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: _kBody,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kCanvas,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kInk, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({this.statuses});

  final List<DayStatus>? statuses;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Metas — Último Ano',
            icon: Icons.grid_view_rounded,
          ),
          const SizedBox(height: 8),
          _buildLegend(),
          const SizedBox(height: 12),
          if (statuses == null || statuses!.isEmpty)
            const _NoDataLabel()
          else
            BudgetHeatmap(
              statuses: statuses!,
              onDayTap: (status) {
                if (!status.hasPurchase) return;
                final snack = SnackBar(
                  content: Text(
                    _tooltipText(status),
                    style: const TextStyle(color: Color(0xFF0e0f0c)),
                  ),
                  backgroundColor: const Color(0xFFe8ebe6),
                  duration: const Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
              },
            ),
        ],
      ),
    );
  }

  static const _weekdayNames = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  static String _tooltipText(DayStatus s) {
    final d =
        '${_weekdayNames[s.date.weekday - 1]}, ${s.date.day.toString().padLeft(2, '0')}/${s.date.month.toString().padLeft(2, '0')}/${s.date.year}';
    final spent = s.totalSpent?.format() ?? '';
    if (s.budgetGoal == null) return '$d — Gasto: $spent';
    return '$d — Gasto: $spent de ${s.budgetGoal!.format()} (meta)';
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(const Color(0xFFE8EBE6), 'Sem compra'),
        const SizedBox(width: 12),
        _legendItem(const Color(0xFFc5edab), 'Sem meta'),
        const SizedBox(width: 12),
        _legendItem(const Color(0xFF054D28), 'Dentro da meta'),
        const SizedBox(width: 12),
        _legendItem(const Color(0xFFA7000D), 'Excedeu'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: _kMute, fontSize: 10)),
      ],
    );
  }
}

class _NoDataLabel extends StatelessWidget {
  const _NoDataLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'Sem dados para o período',
          style: TextStyle(color: _kMute, fontSize: 14),
        ),
      ),
    );
  }
}
