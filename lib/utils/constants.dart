import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Gift',
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
    'Food': Icons.restaurant,
    'Bills': Icons.receipt,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_cart,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Education': Icons.school,
    'Travel': Icons.flight,
    'Other': Icons.more_horiz,
  };
}