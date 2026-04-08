import 'package:flutter/material.dart';
import 'package:lookup/utils/notifications.dart';
import 'package:lookup/database/database_helper.dart';
import 'package:lookup/models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Transaction> _transactions = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  // Filtered transactions by date range
  List<Transaction> get filteredTransactions {
    DateTime startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    DateTime endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    return _transactions
        .where(
          (t) =>
              t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Get total income
  double get totalIncome {
    return filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  // Get total expense
  double get totalExpense {
    return filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  // Get balance
  double get balance => totalIncome - totalExpense;

  // Check if spending exceeds income and send notification
  Future<void> checkSpendingAlert(int userId) async {
    double totalExpense = await _db.getTotalByType(
      userId,
      TransactionType.expense,
      startDate: DateTime(_selectedDate.year, _selectedDate.month, 1),
      endDate: DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
    );

    double totalIncome = await _db.getTotalByType(
      userId,
      TransactionType.income,
      startDate: DateTime(_selectedDate.year, _selectedDate.month, 1),
      endDate: DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
    );

    if (totalExpense > totalIncome && totalIncome > 0) {
      await Notifications.showSpendingAlert(totalExpense - totalIncome);
    }
  }

  Future<void> loadTransactions(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;

    try {
      _transactions = await _db.getTransactionsByUser(
        userId,
        startDate:
            startDate ?? DateTime(_selectedDate.year, _selectedDate.month, 1),
        endDate:
            endDate ?? DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      int id = await _db.insertTransaction(transaction);
      transaction.id = id;
      _transactions.insert(0, transaction);

      // Check spending alert
      await checkSpendingAlert(transaction.userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateTransaction(transaction);
      int index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }

      // Check spending alert
      await checkSpendingAlert(transaction.userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(int id, int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);

      // Check spending alert after deletion
      await checkSpendingAlert(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<Map<String, double>> getCategoryTotals(
    int userId,
    TransactionType type,
  ) async {
    return await _db.getCategoryTotals(
      userId,
      type,
      startDate: DateTime(_selectedDate.year, _selectedDate.month, 1),
      endDate: DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
    );
  }
}
