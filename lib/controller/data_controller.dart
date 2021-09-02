import 'package:allowance/model/transaction.dart';
import 'package:allowance/model/user.dart';
import 'package:allowance/utils/boxes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataController extends GetxController {
  final _data = GetStorage();
  late bool _isIntro = Boxes.getTransactions().values.toList().cast<User>().length == 0 ? _isIntro = true : _isIntro = false;
  late String _userName = _data.read('userName');
  late double _currentBalance = double.parse(_data.read('currentBalance'));
  late List<User> _listOfUserFromDb = Boxes.getTransactions().values.toList().cast<User>();
  late List<User> _incomeOnly = _listOfUserFromDb.where((element) => element.transactionList[0].isExpense != true).toList();

  //getters
  bool get isIntro => _isIntro;
  String get userName => _userName;
  double get currentBalance => _currentBalance;
  List<User> get listOfUserFromDb => _listOfUserFromDb;
  List<User> get incomeOnly => _incomeOnly;

  //setters
  void setIsIntro(bool newValue) {
    _isIntro = newValue;
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }

  void createNewUser({required String userName, currentBalance}) {
    _data.write('userName', userName.trim());
    _data.write('currentBalance', currentBalance.trim());
    final newUser = User()
      ..userName = userName.trim()
      ..currentBalance = double.parse(currentBalance.trim())
      ..transactionList = [];
    final box = Boxes.getTransactions();
    box.add(newUser);
    setIsIntro(false);
    update();
  }

  void createNewTransaction({required String name, amount, type, required bool isExpense}) {
    final _newTransaction = new Transaction(
      name: name.trim(),
      amount: double.parse(amount),
      type: type,
      createdDate: DateTime.now(),
      isExpense: isExpense,
    );
    final user = User()
      ..userName = _userName
      ..currentBalance = _currentBalance
      ..transactionList = [_newTransaction];

    final box = Boxes.getTransactions();
    box.add(user);
    _listOfUserFromDb = Boxes.getTransactions().values.toList().cast<User>();
    update();
  }

  @override
  void onClose() {
    Hive.box('user').close();
    super.onClose();
  }
}
