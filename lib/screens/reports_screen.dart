import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/loan_provider.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, LoanProvider>(
      builder: (context, transactionProvider, loanProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports & Insights'),
          ),
          body: Column(
            children: [
              // Tab selector
              _buildTabSelector(),
              
              // Date range selector
              _buildDateRangeSelector(),
              
              const SizedBox(height: 16),
              
              // Content based on selected tab
              Expanded(
                child: _buildTabContent(transactionProvider, loanProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectTab(0),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Charts',
                    style: TextStyle(
                      color: _selectedTab == 0 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectTab(1),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Summary',
                    style: TextStyle(
                      color: _selectedTab == 1 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              title: Text('From: ${DateFormat('dd/MM/yyyy').format(_startDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: _endDate,
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text('To: ${DateFormat('dd/MM/yyyy').format(_endDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endDate = date;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(TransactionProvider transactionProvider, LoanProvider loanProvider) {
    switch (_selectedTab) {
      case 0:
        return _buildChartsTab(transactionProvider);
      case 1:
        return _buildSummaryTab(transactionProvider, loanProvider);
      default:
        return const SizedBox();
    }
  }

  Widget _buildChartsTab(TransactionProvider transactionProvider) {
    final transactions = transactionProvider.getTransactionsByDateRange(_startDate, _endDate);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Income vs Expense Chart
          _buildIncomeExpenseChart(transactions),
          
          const SizedBox(height: 16),
          
          // Category Distribution Chart
          _buildCategoryDistributionChart(transactions),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(List<Transaction> transactions) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Income vs Expense',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: income,
                      title: 'Income',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: expense,
                      title: 'Expense',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegend('Income', Colors.green, income),
                _buildLegend('Expense', Colors.red, expense),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionChart(List<Transaction> transactions) {
    final categoryMap = <String, double>{};
    
    for (final transaction in transactions) {
      categoryMap[transaction.category] = 
          (categoryMap[transaction.category] ?? 0) + transaction.amount;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Category Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  barGroups: categoryMap.entries.map((entry) {
                    return BarChartGroupData(
                      x: categoryMap.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index >= 0 && index < categoryMap.keys.length) {
                            return SideTitleWidget(
                              axisSide: AxisSide.bottom,
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  categoryMap.keys.elementAt(index),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
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
    );
  }

  Widget _buildLegend(String title, Color color, double value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$title: LKR ${value.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildSummaryTab(TransactionProvider transactionProvider, LoanProvider loanProvider) {
    final transactions = transactionProvider.getTransactionsByDateRange(_startDate, _endDate);
    
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSummaryCard('Total Income', income, Colors.green),
              _buildSummaryCard('Total Expense', expense, Colors.red),
              _buildSummaryCard('Balance', balance, Colors.blue),
              _buildSummaryCard('Loans Given', loanProvider.totalLoansGiven, Colors.orange),
              _buildSummaryCard('Loans Taken', loanProvider.totalLoansTaken, Colors.purple),
              _buildSummaryCard('Net Loan', loanProvider.netLoanBalance, Colors.teal),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      AppConstants.categoryIcons[transaction.category] ?? Icons.category,
                      color: transaction.type == TransactionType.income 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    title: Text(transaction.title),
                    subtitle: Text(transaction.category),
                    trailing: Text(
                      '${transaction.type == TransactionType.income ? '+' : '-'}LKR ${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.type == TransactionType.income 
                            ? Colors.green 
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color) {
    return Container(
      width: 150,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'LKR ${value.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }
}