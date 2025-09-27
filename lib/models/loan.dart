import 'package:hive/hive.dart';

part 'loan.g.dart';

@HiveType(typeId: 2)
class Loan {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  LoanType type;

  @HiveField(5)
  bool isSettled;

  @HiveField(6)
  DateTime? settledDate;

  @HiveField(7)
  String? description;

  Loan({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    this.isSettled = false,
    this.settledDate,
    this.description,
  });
}

@HiveType(typeId: 3)
enum LoanType {
  @HiveField(0)
  given,
  @HiveField(1)
  taken,
}