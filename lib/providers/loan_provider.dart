import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/loan.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import 'transaction_provider.dart';

class LoanProvider with ChangeNotifier {
  List<Loan> _loans = [];

  List<Loan> get loans => _loans;

  double get totalLoansGiven {
    return _loans
        .where((l) => l.type == LoanType.given && !l.isSettled)
        .fold(0.0, (sum, l) => sum + l.amount);
  }

  double get totalLoansTaken {
    return _loans
        .where((l) => l.type == LoanType.taken && !l.isSettled)
        .fold(0.0, (sum, l) => sum + l.amount);
  }

  double get netLoanBalance {
    return totalLoansGiven - totalLoansTaken;
  }

  List<Loan> get unsettledLoans {
    return _loans.where((l) => !l.isSettled).toList();
  }

  List<Loan> get settledLoans {
    return _loans.where((l) => l.isSettled).toList();
  }

  Future<void> initialize() async {
    await loadLoans();
  }

  Future<void> loadLoans() async {
    _loans = DatabaseService.getAllLoans();
    _loans.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> refreshAllData(BuildContext? context) async {
    await loadLoans();
    if (context != null) {
      try {
        // Refresh transaction data as well
        final transactionProvider =
            Provider.of<TransactionProvider>(context, listen: false);
        await transactionProvider.loadTransactions();

        // Notify UI that data has been refreshed
        notifyListeners();
      } catch (e) {
        print('Error refreshing data: $e');
      }
    }
  }

  // Special method for refreshing after loan settlement
  Future<void> refreshAfterSettlement(BuildContext context) async {
    // First refresh transactions as they're affected by the settlement
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    await transactionProvider.loadTransactions();

    // Then refresh loans
    await loadLoans();

    // Make sure UI is updated
    notifyListeners();
    transactionProvider.notifyListeners();
  }

  Future<void> addLoan(Loan loan) async {
    await DatabaseService.addLoan(loan);

    // Create corresponding transaction
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: loan.type == LoanType.taken
          ? 'Loan Received'
          : 'Loan Given to ${loan.name}',
      amount: loan.amount,
      category: loan.type == LoanType.taken ? 'Loan Received' : 'Loan Given',
      date: loan.date,
      type: loan.type == LoanType.taken
          ? TransactionType
              .income // When we take a loan, we receive money (income)
          : TransactionType
              .expense, // When we give a loan, money goes out (expense)
      description: loan.description,
    );

    await DatabaseService.addTransaction(transaction);
    await refreshAllData(null);
  }

  Future<void> updateLoan(String id, Loan loan) async {
    await DatabaseService.updateLoan(id, loan);
    await refreshAllData(null);
  }

  Future<void> deleteLoan(String id) async {
    await DatabaseService.deleteLoan(id);
    await refreshAllData(null);
  }

  Future<void> settleLoan(String id,
      {double? amount, BuildContext? context}) async {
    final loan = _loans.firstWhere((l) => l.id == id);
    final settleAmount = amount ?? loan.amount;

    // Create settlement transaction
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: loan.type == LoanType.taken
          ? 'Loan Payment to ${loan.name}'
          : 'Loan Settlement from ${loan.name}',
      amount: settleAmount,
      category:
          loan.type == LoanType.taken ? 'Loan Payment' : 'Loan Settlement',
      date: DateTime.now(),
      // When settling a loan:
      // For taken loans: We pay money back (expense)
      // For given loans: We receive money back (income)
      type: loan.type == LoanType.taken
          ? TransactionType
              .expense // When we settle a taken loan, we pay money (expense)
          : TransactionType
              .income, // When we settle a given loan, we receive money (income)
      description:
          'Settlement for loan ${loan.type == LoanType.taken ? 'taken from' : 'given to'} ${loan.name}',
    );

    await DatabaseService.addTransaction(transaction);

    if (amount != null && amount < loan.amount) {
      // Partial settlement - create a new loan for the remaining amount
      final remainingAmount = loan.amount - amount;
      final newLoan = Loan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: loan.name,
        amount: remainingAmount,
        date: loan.date,
        type: loan.type,
        isSettled: false,
        description: loan.description,
      );

      await DatabaseService.addLoan(newLoan);

      // Update the original loan to be settled for the partial amount
      final updatedLoan = Loan(
        id: loan.id,
        name: loan.name,
        amount: amount,
        date: loan.date,
        type: loan.type,
        isSettled: true,
        settledDate: DateTime.now(),
        description: loan.description,
      );

      await DatabaseService.updateLoan(id, updatedLoan);
    } else {
      // Full settlement
      final updatedLoan = Loan(
        id: loan.id,
        name: loan.name,
        amount: loan.amount,
        date: loan.date,
        type: loan.type,
        isSettled: true,
        settledDate: DateTime.now(),
        description: loan.description,
      );
      await DatabaseService.updateLoan(id, updatedLoan);
    }

    if (context != null) {
      await refreshAfterSettlement(context);
    } else {
      await loadLoans();
    }
  }
}
