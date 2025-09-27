import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/loan_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/loan_card.dart';
import '../utils/constants.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import 'add_transaction_screen.dart';
import 'add_loan_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);
    
    await transactionProvider.loadTransactions();
    await loanProvider.loadLoans();
  }

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
                  _buildRecentTransactions(context, transactionProvider, loanProvider),
                  
                  // Recent Loans
                  _buildRecentLoans(context, loanProvider),
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

  Widget _buildRecentTransactions(BuildContext context, TransactionProvider transactionProvider, LoanProvider loanProvider) {
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
                  .map((t) => TransactionCard(
                    transaction: t,
                    onEdit: () => _editTransaction(context, transactionProvider, t),
                    onDelete: () => _deleteTransaction(context, transactionProvider, t.id),
                  ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentLoans(BuildContext context, LoanProvider loanProvider) {
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
                  .map((l) => LoanCard(
                    loan: l,
                    onEdit: () => _editLoan(context, loanProvider, l),
                    onDelete: () => _deleteLoan(context, loanProvider, l.id),
                    onSettle: (amount) => _settleLoan(context, loanProvider, l.id, amount),
                  ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return const CustomSpeedDial();
  }

  void _editTransaction(BuildContext context, TransactionProvider provider, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    ).then((_) {
      // Reload data after editing
      provider.loadTransactions();
    });
  }

  void _deleteTransaction(BuildContext context, TransactionProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // No
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTransaction(id);
              Navigator.pop(context, true); // Yes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _editLoan(BuildContext context, LoanProvider provider, Loan loan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLoanScreen(loan: loan),
      ),
    ).then((_) {
      // Reload data after editing
      provider.loadLoans();
    });
  }

  void _deleteLoan(BuildContext context, LoanProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: const Text('Are you sure you want to delete this loan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // No
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteLoan(id);
              Navigator.pop(context, true); // Yes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loan deleted')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _settleLoan(BuildContext context, LoanProvider provider, String id, double amount) {
    provider.settleLoan(id, amount: amount);
    String message = amount == provider.loans.firstWhere((l) => l.id == id).amount
        ? 'Loan fully settled'
        : 'Loan partially settled (LKR ${amount.toStringAsFixed(2)})';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToAddTransaction(BuildContext context, TransactionType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(initialType: type),
      ),
    ).then((_) {
      // Reload data after adding
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      transactionProvider.loadTransactions();
      loanProvider.loadLoans();
    });
  }

  void _navigateToAddLoan(BuildContext context, LoanType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLoanScreen(initialType: type),
      ),
    ).then((_) {
      // Reload data after adding
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      transactionProvider.loadTransactions();
      loanProvider.loadLoans();
    });
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
    ).then((_) {
      // Reload data after adding
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      transactionProvider.loadTransactions();
      loanProvider.loadLoans();
    });
  }

  void _navigateToAddLoan(BuildContext context, LoanType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLoanScreen(initialType: type),
      ),
    ).then((_) {
      // Reload data after adding
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      transactionProvider.loadTransactions();
      loanProvider.loadLoans();
    });
  }
}