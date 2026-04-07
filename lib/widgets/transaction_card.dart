import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lookup/models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  const TransactionCard({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIcome = transaction.type == TransactionType.income;
    final amountColor = isIcome ? Colors.green : Colors.red;
    final amountPrefix = isIcome ? '+' : '-';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon/Emodji
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: (isIcome ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    transaction.icon ?? '❓',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.category} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (transaction.note != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.note!,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Amount
              Text(
                '$amountPrefix XAF: ${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
