import 'package:allowance/model/transaction.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String userName;

  @HiveField(1)
  late double currentBalance;

  @HiveField(2)
  late List<Transaction> transactionList = [];
}
