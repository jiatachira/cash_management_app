import 'package:flutter/material.dart';
import '../models/loan.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSettle;

  const LoanCard({
    Key? key,
    required this.loan,
    this.onEdit,
    this.onDelete,
    this.onSettle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              loan.type == LoanType.given 
                  ? Icons.monetization_on 
                  : Icons.money_off,
              color: loan.type == LoanType.given 
                  ? Colors.blue 
                  : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loan.type == LoanType.given ? 'Given' : 'Taken',
                    style: TextStyle(
                      fontSize: 12,
                      color: loan.type == LoanType.given 
                          ? Colors.blue 
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loan.date.toString().split(' ')[0],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LKR ${loan.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (loan.isSettled) ...[
                  const Text(
                    'Settled',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: onSettle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text('Settle'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}