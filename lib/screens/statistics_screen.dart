import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lookup/generated/app_localizations.dart';
import 'package:lookup/models/transaction.dart';
import 'package:lookup/providers/auth_provider.dart';
import 'package:lookup/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Month';
  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await transactionProvider.loadTransactions(authProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },

            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(value: period, child: Text(period));
            }).toList(),
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final totalIncome = transactionProvider.totalIncome;
          final totalExpense = transactionProvider.totalExpense;
          final balance = transactionProvider.balance;

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );

              if (authProvider.currentUser != null) {
                await transactionProvider.loadTransactions(
                  authProvider.currentUser!.id!,
                );
              }
            },

            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // summary card
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          AppLocalizations.of(context)!.income,
                          totalIncome,
                          Icons.arrow_upward_rounded,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryCard(
                          AppLocalizations.of(context)!.expense,
                          totalExpense,
                          Icons.arrow_downward_rounded,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryCard(
                    AppLocalizations.of(context)!.balance,
                    balance,
                    Icons.account_balance_wallet_rounded,
                    balance >= 0 ? Color(0xFF264444) : Colors.orange,
                    isBalance: true,
                  ),
                  SizedBox(height: 20),

                  // Income vs Expense chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.incomeVsExpense,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY:
                                    (totalIncome > totalExpense
                                        ? totalIncome
                                        : totalExpense) *
                                    1.2,
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: totalIncome,
                                        color: Colors.green,
                                        width: 30,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: totalExpense,
                                        color: Colors.red,
                                        width: 30,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const titles = ['Income', 'Expense'];
                                        if (value.toInt() < titles.length) {
                                          return Text(titles[value.toInt()]);
                                        }
                                        return Text(' ');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 90,
                                      getTitlesWidget: (value, meta) {
                                        return Text('xaf:${value.toInt()}');
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //Expense Categories
                  FutureBuilder<Map<String, double>>(
                    future: transactionProvider.getCategoryTotals(
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).currentUser!.id!,
                      TransactionType.expense,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.noExpenseDataAvailable,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        );
                      }

                      final categories = snapshot.data!;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.expenseByCategory,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              ...categories.entries.map((entry) {
                                final percentage =
                                    (entry.value / totalExpense * 100);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key),
                                          Text(
                                            'xaf: ${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)})%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.red.withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Income Categories
                  FutureBuilder<Map<String, double>>(
                    future: transactionProvider.getCategoryTotals(
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).currentUser!.id!,
                      TransactionType.income,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final categories = snapshot.data!;
                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.incomeByCategory,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              ...categories.entries.map((entry) {
                                final percentage =
                                    (entry.value / totalIncome * 100);
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key),
                                          Text(
                                            'xaf: ${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)})%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: Colors.grey[200],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.green.withValues(
                                                alpha: 0.8,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    IconData icon,
    Color color, {
    bool isBalance = false,
  }) {
    return Card(
      elevation: isBalance ? 4 : 2,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: isBalance
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isBalance ? 0.3 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isBalance ? Colors.white : color,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isBalance ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'xaf: ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isBalance ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
