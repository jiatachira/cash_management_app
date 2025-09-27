import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/loan.dart';

class DatabaseService {
  static const String transactionBox = 'transactions';
  static const String loanBox = 'loans';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(LoanAdapter());
    Hive.registerAdapter(LoanTypeAdapter());
    
    await Hive.openBox<Transaction>(transactionBox);
    await Hive.openBox<Loan>(loanBox);
  }

  // Transaction methods
  static Box<Transaction> get transactionBoxInstance => Hive.box<Transaction>(transactionBox);

  static Future<void> addTransaction(Transaction transaction) async {
    await transactionBoxInstance.add(transaction);
  }

  static List<Transaction> getAllTransactions() {
    return transactionBoxInstance.values.toList();
  }

  static Future<void> updateTransaction(String id, Transaction transaction) async {
    final box = transactionBoxInstance;
    final key = box.keys.firstWhere((key) => box.get(key)!.id == id);
    await box.put(key, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    final box = transactionBoxInstance;
    final key = box.keys.firstWhere((key) => box.get(key)!.id == id);
    await box.delete(key);
  }

  // Loan methods
  static Box<Loan> get loanBoxInstance => Hive.box<Loan>(loanBox);

  static Future<void> addLoan(Loan loan) async {
    await loanBoxInstance.add(loan);
  }

  static List<Loan> getAllLoans() {
    return loanBoxInstance.values.toList();
  }

  static Future<void> updateLoan(String id, Loan loan) async {
    final box = loanBoxInstance;
    final key = box.keys.firstWhere((key) => box.get(key)!.id == id);
    await box.put(key, loan);
  }

  static Future<void> deleteLoan(String id) async {
    final box = loanBoxInstance;
    final key = box.keys.firstWhere((key) => box.get(key)!.id == id);
    await box.delete(key);
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}