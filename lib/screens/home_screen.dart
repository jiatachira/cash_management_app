import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/loan_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/loan_card.dart';
import '../utils/constants.dart';
import '../models/transaction.dart'; // Add this import for TransactionType
import '../models/loan.dart'; // Add this import for LoanType
import 'add_transaction_screen.dart';
import 'add_loan_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, LoanProvider>(
      builder: (context, transactionProvider, loanProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cash Manager'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await transactionProvider.loadTransactions();
              await loanProvider.loadLoans();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Summary Cards
                  _buildSummaryCards(transactionProvider, loanProvider),
                  
                  // Recent Transactions
                  _buildRecentTransactions(transactionProvider),
                  
                  // Recent Loans
                  _buildRecentLoans(loanProvider),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(context),
        );
      },
    );
  }

  Widget _buildSummaryCards(TransactionProvider transactionProvider, LoanProvider loanProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildSummaryCard(
            'Income',
            'LKR ${transactionProvider.monthlyIncome.toStringAsFixed(2)}',
            Colors.green,
          ),
          _buildSummaryCard(
            'Expense',
            'LKR ${transactionProvider.monthlyExpense.toStringAsFixed(2)}',
            Colors.red,
          ),
          _buildSummaryCard(
            'Balance',
            'LKR ${transactionProvider.monthlyBalance.toStringAsFixed(2)}',
            Colors.blue,
          ),
          _buildSummaryCard(
            'Loans',
            'LKR ${loanProvider.netLoanBalance.toStringAsFixed(2)}',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
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
              value,
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

  Widget _buildRecentTransactions(TransactionProvider transactionProvider) {
    final transactions = transactionProvider.monthlyTransactions.take(5).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'This Month',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Center(
              child: Text('No transactions yet'),
            )
          else
            Column(
              children: transactions
                  .map((t) => TransactionCard(transaction: t))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentLoans(LoanProvider loanProvider) {
    final loans = loanProvider.unsettledLoans.take(3).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Loans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (loans.isEmpty)
            const Center(
              child: Text('No loans yet'),
            )
          else
            Column(
              children: loans
                  .map((l) => LoanCard(loan: l))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return const CustomSpeedDial();
  }

  void _navigateToAddTransaction(BuildContext context, TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(initialType: type),
      ),
    );
  }

  void _navigateToAddLoan(BuildContext context, LoanType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLoanScreen(initialType: type),
      ),
    );
  }
}

// Custom SpeedDial implementation with proper positioning
class CustomSpeedDial extends StatefulWidget {
  const CustomSpeedDial({Key? key}) : super(key: key);

  @override
  State<CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<CustomSpeedDial> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Add Income Button
        Positioned(
          bottom: 60 + (50 * _animation.value),
          right: 16,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Visibility(
                  visible: _animation.value > 0.1,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Add Income',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          mini: true,
                          onPressed: () => _navigateToAddTransaction(context, TransactionType.income),
                          child: const Icon(Icons.money),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Add Expense Button
        Positioned(
          bottom: 120 + (50 * _animation.value),
          right: 16,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Visibility(
                  visible: _animation.value > 0.1,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Add Expense',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          mini: true,
                          onPressed: () => _navigateToAddTransaction(context, TransactionType.expense),
                          child: const Icon(Icons.money_off),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Add Loan Given Button
        Positioned(
          bottom: 180 + (50 * _animation.value),
          right: 16,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Visibility(
                  visible: _animation.value > 0.1,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Add Loan Given',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          mini: true,
                          onPressed: () => _navigateToAddLoan(context, LoanType.given),
                          child: const Icon(Icons.monetization_on),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Add Loan Taken Button
        Positioned(
          bottom: 240 + (50 * _animation.value),
          right: 16,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Opacity(
                opacity: _animation.value,
                child: Visibility(
                  visible: _animation.value > 0.1,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Add Loan Taken',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          mini: true,
                          onPressed: () => _navigateToAddLoan(context, LoanType.taken),
                          child: const Icon(Icons.money_off),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Main FAB
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              if (_isOpen) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 0.5 * 3.14159, // 90 degrees rotation
                  child: const Icon(Icons.add),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToAddTransaction(BuildContext context, TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(initialType: type),
      ),
    );
  }

  void _navigateToAddLoan(BuildContext context, LoanType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLoanScreen(initialType: type),
      ),
    );
  }
}