import 'package:flutter/material.dart';
import '../models/loan.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(double)? onSettle;

  const LoanCard({
    Key? key,
    required this.loan,
    this.onEdit,
    this.onDelete,
    this.onSettle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(loan.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left - delete
          return await _showDeleteConfirmationDialog(context);
        } else {
          // Swipe right - edit
          if (onEdit != null) onEdit!();
          return false; // Don't dismiss the card
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart && onDelete != null) {
          onDelete!();
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onLongPress: () {
          _showContextMenu(context);
        },
        child: Card(
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
                        onPressed: () => _showSettleDialog(context),
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
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
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
            onPressed: () => Navigator.pop(context, true), // Yes
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox target = context.findRenderObject() as RenderBox;
    final Offset position = target.localToGlobal(Offset.zero, ancestor: overlay);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + target.size.height,
        position.dx + target.size.width,
        position.dy + target.size.height + 150,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.edit, size: 18),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
          onTap: () {
            if (onEdit != null) onEdit!();
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.delete, size: 18),
              const SizedBox(width: 8),
              const Text('Delete'),
            ],
          ),
          onTap: () {
            if (onDelete != null) onDelete!();
          },
        ),
        if (!loan.isSettled)
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(Icons.payment, size: 18),
                const SizedBox(width: 8),
                const Text('Settle'),
              ],
            ),
            onTap: () => _showSettleDialog(context),
          ),
      ],
    );
  }

  void _showSettleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        double amountToSettle = loan.amount;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Settle Loan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Amount: LKR ${loan.amount.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: loan.amount.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Amount to Settle',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              double parsedValue = double.tryParse(value) ?? 0;
                              setState(() {
                                amountToSettle = parsedValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (amountToSettle > 0 && amountToSettle <= loan.amount) {
                      if (onSettle != null) onSettle!(amountToSettle);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid amount'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Settle'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}