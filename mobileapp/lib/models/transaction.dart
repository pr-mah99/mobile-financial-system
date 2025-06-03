// lib/models/transaction.dart
import 'package:flutter/material.dart';

enum TransactionStatus { pending, completed, failed, cancelled }

class Transaction {
  final int id;
  final int senderId;
  final int recipientId;
  final double amount;
  final TransactionStatus status;
  final String transactionType;
  final String? description;
  final String referenceNumber;
  final String? createdAt;
  final String? updatedAt;

  Transaction({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.amount,
    required this.status,
    required this.transactionType,
    this.description,
    required this.referenceNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      amount: double.parse(json['amount'].toString()),
      status: _parseStatus(json['status']),
      transactionType: json['transaction_type'],
      description: json['description'],
      referenceNumber: json['reference_number'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static TransactionStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.completed:
        return 'مكتملة';
      case TransactionStatus.pending:
        return 'معلقة';
      case TransactionStatus.failed:
        return 'فاشلة';
      case TransactionStatus.cancelled:
        return 'ملغية';
    }
  }
}