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
  late List<Transaction> _incomeTransactions;
  late List<Transaction> _expenseTransactions;
  late Box<Transaction> _transactionBox;

  List<Transaction> get transactions => _transactions;
  List<Transaction> get incomeTransactions => _incomeTransactions;
  List<Transaction> get expenseTransactions => _expenseTransactions;

  User get currentUser => _currentUser;

  DataController() {
    _userBox = Hive.box<User>(userBoxName);
    _transactionBox = Hive.box<Transaction>(transactionBoxName);
    List<User> _userList = _userBox.values.toList();
    print('found ${_userList.length} user');
    _currentUser = _userList.isEmpty ? User(name: "", currentBalance: 0, id: "") : _userBox.values.first;
    //
    _transactions = [];
    _transactionBox.values.forEach((element) {
      _transactions.add(element);
    });
    _incomeTransactions = _transactions.where((element) => element.isIncome).toList();
    _expenseTransactions = _transactions.where((element) => element.isIncome == false).toList();
  }

  addUser(User user) {
    _currentUser = user;
    _userBox.add(user);
    update();
  }

  _updateLists() {
    _incomeTransactions = _transactions.where((element) => element.isIncome).toList();
    _expenseTransactions = _transactions.where((element) => element.isIncome == false).toList();
    update();
  }

  addTransaction(Transaction transaction, BuildContext context) {
    _transactions.add(transaction);
    _transactionBox.add(transaction);
    if (transaction.isIncome) {
      _currentUser.currentBalance += transaction.amount;
      _userBox.putAt(0, _currentUser);
    } else {
      _currentUser.currentBalance -= transaction.amount;
      _userBox.putAt(0, _currentUser);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction Added',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xfff2f2f2),
      ),
    );
    _updateLists();
    update();
  }

  removeTransaction(Transaction transaction) {
    _transactionBox.deleteAt(transactions.indexOf(transaction));
    _transactions.removeWhere((element) => element.id == transaction.id);
    if (transaction.isIncome) {
      _currentUser.currentBalance -= transaction.amount;
      _userBox.putAt(0, _currentUser);
    } else {
      _currentUser.currentBalance += transaction.amount;
      _userBox.putAt(0, _currentUser);
    }
    _updateLists();
    update();
  }
}
