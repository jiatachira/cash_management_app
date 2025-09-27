import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/loan.dart';
import '../providers/loan_provider.dart';

class AddLoanScreen extends StatefulWidget {
  final Loan? loan;
  final LoanType? initialType;

  const AddLoanScreen({
    Key? key,
    this.loan,
    this.initialType,
  }) : super(key: key);

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  LoanType? _selectedType;
  DateTime _selectedDate = DateTime.now();
  bool _isSettled = false;

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      _nameController.text = widget.loan!.name;
      _amountController.text = widget.loan!.amount.toString();
      _descriptionController.text = widget.loan!.description ?? '';
      _selectedType = widget.loan!.type;
      _selectedDate = widget.loan!.date;
      _isSettled = widget.loan!.isSettled;
    } else {
      _selectedType = widget.initialType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loan != null ? 'Edit Loan' : 'Add Loan'),
        actions: [
          TextButton(
            onPressed: _saveLoan,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type Selection
              _buildTypeSelection(),
              
              const SizedBox(height: 16),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Person Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'LKR ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date Picker
              _buildDatePicker(),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              // Settled Checkbox
              if (widget.loan != null)
                CheckboxListTile(
                  title: const Text('Settled'),
                  value: _isSettled,
                  onChanged: (value) {
                    setState(() {
                      _isSettled = value!;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<LoanType>(
            title: const Text('Given'),
            value: LoanType.given,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<LoanType>(
            title: const Text('Taken'),
            value: LoanType.taken,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: Text('Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
    );
  }

  void _saveLoan() async {
    if (_formKey.currentState!.validate()) {
      final loan = Loan(
        id: widget.loan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: _selectedType!,
        isSettled: widget.loan != null ? _isSettled : false,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      final provider = Provider.of<LoanProvider>(context, listen: false);
      
      if (widget.loan != null) {
        await provider.updateLoan(widget.loan!.id, loan);
      } else {
        await provider.addLoan(loan);
      }

      Navigator.pop(context);
    }
  }
}