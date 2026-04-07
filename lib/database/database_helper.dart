import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';

import 'package:lookup/models/user.dart';
import 'package:lookup/models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        avatar TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        icon TEXT,
        note TEXT,
        date TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // User CRUD operations
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmailOrUsername(String identifier) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [identifier, identifier],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> checkUserCredentials(String identifier, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: '(email = ? OR username = ?) AND password = ?',
      whereArgs: [identifier, identifier, password],
    );
    return maps.isNotEmpty;
  }

  Future<int> updateUser(User user) async {
    Database db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(Transaction transaction) async {
    Database db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactionsByUser(
    int userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Database db = await database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (startDate != null && endDate != null) {
      whereClause += ' AND date BETWEEN ? AND ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }

    List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<Transaction?> getTransactionById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    Database db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalByType(
    int userId,
    TransactionType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Database db = await database;
    String whereClause = 'user_id = ? AND type = ?';
    List<dynamic> whereArgs = [userId, type.toString().split('.').last];

    if (startDate != null && endDate != null) {
      whereClause += ' AND date BETWEEN ? AND ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }

    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE $whereClause',
      whereArgs,
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getCategoryTotals(
    int userId,
    TransactionType type, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Database db = await database;
    String whereClause = 'user_id = ? AND type = ?';
    List<dynamic> whereArgs = [userId, type.toString().split('.').last];

    if (startDate != null && endDate != null) {
      whereClause += ' AND date BETWEEN ? AND ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }

    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE $whereClause GROUP BY category',
      whereArgs,
    );

    Map<String, double> totals = {};
    for (var row in result) {
      totals[row['category']] = row['total'] as double;
    }
    return totals;
  }
}
