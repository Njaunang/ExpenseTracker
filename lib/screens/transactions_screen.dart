import 'package:flutter/material.dart';
import 'package:lookup/generated/app_localizations.dart';
import 'package:lookup/providers/auth_provider.dart';
import 'package:lookup/providers/transaction_provider.dart';
import 'package:lookup/screens/add_transaction_screen.dart';
import 'package:lookup/widgets/transaction_card.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All'; // All, Income, Expense

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await transactionProvider.loadTransactions(authProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var transactions = transactionProvider.filteredTransactions;

          // Apply filter
          if (_filter == 'Income') {
            transactions = transactions
                .where((t) => t.type.toString().split('.').last == 'income')
                .toList();
          } else if (_filter == 'Expense') {
            transactions = transactions
                .where((t) => t.type.toString().split('.').last == 'expense')
                .toList();
          }

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.noTransactions,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(),
                        ),
                      );
                      if (result == true) {
                        _loadData();
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.addTransaction),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.currentUser != null) {
                await transactionProvider.loadTransactions(
                  authProvider.currentUser!.id!,
                );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return TransactionCard(
                  transaction: transactions[index],
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                          transaction: transactions[index],
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterTransactions),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: Text(AppLocalizations.of(context)!.all),
              activeColor: Color(0xFF264444),
              value: 'All',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: Text(AppLocalizations.of(context)!.income),
              value: 'Income',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: Text(AppLocalizations.of(context)!.expense),
              value: 'Expense',
              groupValue: _filter,
              onChanged: (value) {
                setState(() {
                  _filter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
