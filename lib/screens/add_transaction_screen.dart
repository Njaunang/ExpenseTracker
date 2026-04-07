import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lookup/generated/app_localizations.dart';
import 'package:lookup/models/transaction.dart';
import 'package:lookup/providers/auth_provider.dart';
import 'package:lookup/providers/transaction_provider.dart';
import 'package:lookup/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = 'Food';
  String? _icon;
  DateTime _selectedDate = DateTime.now();

  late List<Map<String, dynamic>> _categories;
  bool _categoriesInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _icon = widget.transaction!.icon;
      _selectedDate = widget.transaction!.date;

      if (widget.transaction!.note != null) {
        _noteController.text = widget.transaction!.note!;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_categoriesInitialized) {
      _initializeCategories();
      _categoriesInitialized = true;
      // Set _category to a valid filtered category if not already set
      if (filteredCategories.isNotEmpty &&
          !filteredCategories.any((cat) => cat['name'] == _category)) {
        _category = filteredCategories.first['name'];
        _icon = filteredCategories.first['icon'];
      }
    }
  }

  void _initializeCategories() {
    _categories = [
      {
        'name': AppLocalizations.of(context)!.categoryFood,
        'icon': '🍔',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categoryTransport,
        'icon': '🚗',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categoryShopping,
        'icon': '🛍️',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categoryEntertainment,
        'icon': '🎬',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categoryBills,
        'icon': '💡',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categoryHealthcare,
        'icon': '🏥',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categoryEducation,
        'icon': '📚',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categorySalary,
        'icon': '💰',
        'type': 'income',
      },
      {
        'name': AppLocalizations.of(context)!.categoryFreelance,
        'icon': '💻',
        'type': 'income',
      },
      {
        'name': AppLocalizations.of(context)!.categoryInvestment,
        'icon': '📈',
        'type': 'income',
      },
      {
        'name': AppLocalizations.of(context)!.categoryGift,
        'icon': '🎁',
        'type': 'income',
      },
      {
        'name': AppLocalizations.of(context)!.categoryTravel,
        'icon': '✈️',
        'type': 'expense',
      },
      {
        'name': AppLocalizations.of(context)!.categoryOther,
        'icon': '📝',
        'type': 'expense',
      },
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredCategories {
    return _categories
        .where((cat) => cat['type'] == _type.toString().split('.').last)
        .toList();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020), // Changed from 2026 to 2020
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      // FIX: Check if user is authenticated
      if (authProvider.currentUser == null) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.userNotAuthenticated,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 12,
          );
          Navigator.pop(context);
        }
        return;
      }

      final userId = authProvider.currentUser!.id;
      if (userId == null) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.userIdNotFound,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 12,
          );
        }
        return;
      }

      final transaction = Transaction(
        id: widget.transaction?.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _type,
        category: _category,
        icon:
            _icon ??
            filteredCategories.firstWhere(
                  (cat) => cat['name'] == _category,
                  orElse: () => {
                    'icon': '📝',
                  }, // FIX: Add orElse to avoid errors
                )['icon']
                as String? ??
            '📝',
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _selectedDate,
        userId: userId, // FIX: Use the safely retrieved userId
        createdAt: widget.transaction?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.transaction == null) {
        success = await transactionProvider.addTransaction(transaction);
      } else {
        success = await transactionProvider.updateTransaction(transaction);
      }

      if (success && mounted) {
        Fluttertoast.showToast(
          msg: widget.transaction == null
              ? AppLocalizations.of(context)!.transactionAdded
              : AppLocalizations.of(context)!.transactionUpdated,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 12,
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.failedToSaveTransaction,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 12,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? AppLocalizations.of(context)!.addTransaction
              : AppLocalizations.of(context)!.editTransaction,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // FIX: Add the form key here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment<TransactionType>(
                    value: TransactionType.expense,
                    label: Text(AppLocalizations.of(context)!.expense),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                  ButtonSegment<TransactionType>(
                    value: TransactionType.income,
                    label: Text(AppLocalizations.of(context)!.income),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> selection) {
                  setState(() {
                    _type = selection.first;

                    // reset category when type change
                    final firstCategory = filteredCategories.isNotEmpty
                        ? filteredCategories.first
                        : _categories.first;
                    _category = firstCategory['name'];
                    _icon = firstCategory['icon'];
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.transactionTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.amount,
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyAmount;
                  }
                  if (double.tryParse(value) == null) {
                    return AppLocalizations.of(context)!.emptyAmount;
                  }
                  if (double.parse(value) <= 0) {
                    return AppLocalizations.of(context)!.invalidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category,
                  prefixIcon: const Icon(Icons.category_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: filteredCategories.map<DropdownMenuItem<String>>((
                  category,
                ) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Row(
                      children: [
                        Text(category['icon']),
                        const SizedBox(width: 10),
                        Text(category['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                    final category = filteredCategories.firstWhere(
                      (cat) => cat['name'] == value,
                      orElse: () => {'name': _category, 'icon': '📝'},
                    );
                    _icon = category['icon'];
                  });
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.noteOptional,
                  prefixIcon: const Icon(Icons.note_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: widget.transaction == null
                    ? AppLocalizations.of(context)!.addTransaction
                    : AppLocalizations.of(context)!.updateTransaction,
                onPressed: _saveTransaction,
              ),
              if (widget.transaction != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          AppLocalizations.of(context)!.deleteTransaction,
                        ),
                        content: Text(AppLocalizations.of(context)!.areYouSure),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.delete,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && mounted) {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final transactionProvider =
                          Provider.of<TransactionProvider>(
                            context,
                            listen: false,
                          );

                      // FIX: Check if user is authenticated before deleting
                      if (authProvider.currentUser?.id == null) {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(
                            context,
                          )!.userNotAuthenticated,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 12,
                        );
                        return;
                      }

                      bool success = await transactionProvider
                          .deleteTransaction(
                            widget.transaction!.id!,
                            authProvider.currentUser!.id!,
                          );

                      if (success && mounted) {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.transactionDeleted,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 12,
                        );
                        Navigator.pop(context, true);
                      } else if (mounted) {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(
                            context,
                          )!.failedToDeleteTransaction,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 12,
                        );
                      }
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.deleteTransaction,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
