import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  List<Transaction> get monthlyTransactions {
    final now = DateTime.now();
    return _transactions.where((transaction) {
      return transaction.date.year == now.year && 
             transaction.date.month == now.month;
    }).toList();
  }

  double get monthlyIncome {
    return monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    return monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyBalance {
    return monthlyIncome - monthlyExpense;
  }

  Future<void> initialize() async {
    await loadTransactions();
  }

  Future<void> loadTransactions() async {
    _transactions = DatabaseService.getAllTransactions();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseService.addTransaction(transaction);
    await loadTransactions();
  }

  Future<void> updateTransaction(String id, Transaction transaction) async {
    await DatabaseService.updateTransaction(id, transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await DatabaseService.deleteTransaction(id);
    await loadTransactions();
  }

  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) => 
        t.date.isAfter(start.subtract(const Duration(days: 1))) && 
        t.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }
}