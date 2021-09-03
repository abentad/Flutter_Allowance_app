import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late double amount;
  @HiveField(3)
  late String type;
  @HiveField(4)
  late bool isIncome;
  @HiveField(5)
  late DateTime dateAdded;
  Transaction({required this.amount, required this.dateAdded, required this.id, required this.isIncome, required this.name, required this.type});
}
