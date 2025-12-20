import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String type; // 'income' or 'expense'

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  TransactionModel({
    String? id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  }) : id = id ?? const Uuid().v4();
}
