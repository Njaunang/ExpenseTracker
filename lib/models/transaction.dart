enum TransactionType { income, expense }

class Transaction {
  int? id;
  String title;
  double amount;
  TransactionType type;
  String category;
  String? icon;
  String? note;
  DateTime date;
  int userId;
  DateTime createdAt;
  DateTime? updatedAt;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.icon,
    this.note,
    required this.date,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category,
      'icon': icon,
      'note': note,
      'date': date.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      category: map['category'],
      icon: map['icon'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}
