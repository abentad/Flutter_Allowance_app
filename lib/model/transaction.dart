import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  late String name;
  @HiveField(1)
  late String type;
  @HiveField(2)
  late double amount;
  @HiveField(3)
  late DateTime createdDate = DateTime.now();
  @HiveField(4)
  late bool isExpense = true;

  Transaction({
    required this.name,
    required this.type,
    required this.amount,
    required this.isExpense,
    required this.createdDate,
  });
}
