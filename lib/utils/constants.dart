import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Gift',
    'Loan Received', // When taking a loan
    'Loan Settlement', // When someone pays back their loan
    'Other',
  ];

  static const List<String> expenseCategories = [
    'Food',
    'Bills',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Travel',
    'Loan Payment', // When paying back a loan
    'Loan Given', // When giving a loan to someone
    'Other',
  ];

  static const List<String> allCategories = [
    ...incomeCategories,
    ...expenseCategories,
  ];

  static const Map<String, IconData> categoryIcons = {
    'Salary': Icons.work,
    'Business': Icons.business,
    'Investment': Icons.trending_up,
    'Freelance': Icons.design_services,
    'Gift': Icons.card_giftcard,
    'Loan Received': Icons.arrow_downward,
    'Loan Settlement': Icons.money,
    'Food': Icons.restaurant,
    'Bills': Icons.receipt,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_cart,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Education': Icons.school,
    'Travel': Icons.flight,
    'Loan Payment': Icons.payment,
    'Loan Given': Icons.arrow_upward,
    'Other': Icons.more_horiz,
  };
}
