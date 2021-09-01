import 'package:allowance/model/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Boxes {
  static Box<User> getTransactions() => Hive.box<User>('user');
}
