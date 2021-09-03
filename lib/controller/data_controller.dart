import 'package:allowance/constants.dart';
import 'package:allowance/model/transaction.dart';
import 'package:allowance/model/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataController extends GetxController {
  late User _currentUser;
  late Box<User> _userBox;
  late List<Transaction> _transactions;
  late Box<Transaction> _transactionBox;

  List<Transaction> get transactions => _transactions;
  User get currentUser => _currentUser;

  DataController() {
    _userBox = Hive.box<User>(userBoxName);
    _transactionBox = Hive.box<Transaction>(transactionBoxName);
    //TODO: currentUser issue
    List<User> _userList = _userBox.values.toList();
    _currentUser = _userList.isEmpty ? User(name: "", currentBalance: 0, id: "") : _userBox.values.first;
    //
    _transactions = [];
    _transactionBox.values.forEach((element) {
      _transactions.add(element);
    });
    print(_transactions.length);
  }

  addUser(User user) {
    _currentUser = user;
    _userBox.add(user);
    update();
  }

  addTransaction(Transaction transaction, BuildContext context) {
    _transactions.add(transaction);
    _transactionBox.add(transaction);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction Added',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xfff2f2f2),
      ),
    );
    update();
  }

  removeTransaction(Transaction transaction) {
    _transactionBox.deleteAt(transactions.indexOf(transaction));
    _transactions.removeWhere((element) => element.id == transaction.id);
    update();
  }
}
