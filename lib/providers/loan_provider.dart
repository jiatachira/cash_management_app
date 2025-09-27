import 'package:flutter/foundation.dart';
import '../models/loan.dart';
import '../services/database_service.dart';

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

  Future<void> loadLoans() async {
    _loans = DatabaseService.getAllLoans();
    _loans.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addLoan(Loan loan) async {
    await DatabaseService.addLoan(loan);
    await loadLoans();
  }

  Future<void> updateLoan(String id, Loan loan) async {
    await DatabaseService.updateLoan(id, loan);
    await loadLoans();
  }

  Future<void> deleteLoan(String id) async {
    await DatabaseService.deleteLoan(id);
    await loadLoans();
  }

  Future<void> settleLoan(String id) async {
    final loan = _loans.firstWhere((l) => l.id == id);
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
    await loadLoans();
  }
}