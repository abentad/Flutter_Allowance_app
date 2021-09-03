import 'dart:math';

import 'package:allowance/controller/data_controller.dart';
import 'package:allowance/model/transaction.dart';
import 'package:allowance/model/user.dart';
import 'package:allowance/view/chart_screen.dart';
import 'package:allowance/view/edit_screen.dart';
import 'package:allowance/view/setting_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dataController = Get.find<DataController>();

  int _groupValue = 0;
  int _bottomNavValue = 0;
  bool _isIncome = true;

  TextEditingController _transactionNameController = TextEditingController();
  TextEditingController _transactionAmountController = TextEditingController();
  TextEditingController _transactionTypeController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _currentBalanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    List<Widget> homeContent = [
      buildAll(size),
      buildIncome(size),
      buildExpenses(size),
    ];
    List<Widget> contents = [
      buildHome(size, homeContent),
      buildMode(),
      buildChart(),
      buildSetting(),
    ];

    return GetBuilder<DataController>(
      builder: (controller) => Scaffold(
        body: contents[_bottomNavValue],
        // bottomNavigationBar: isIntro ? null : buildBottomNavBar(),
        // floatingActionButton: isIntro
        //TODO: implement bottom nav bar
        // bottomNavigationBar: _dataController.currentUser.name == "" ? null : buildBottomNavBar(),
        floatingActionButton: controller.currentUser.name == ""
            ? null
            : FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
                    context: context,
                    builder: (context) => SingleChildScrollView(
                      child: buildSheet(size),
                    ),
                  );
                },
                backgroundColor: Colors.black,
                child: Icon(Icons.add, color: Colors.white),
              ),
      ),
    );
  }

  Widget buildSheet(Size size) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: size.height * 0.04),
          Text(
            'Add Transaction',
            style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: size.height * 0.04),
          buildFormField(controller: _transactionNameController, hintText: "Name", keyboardType: TextInputType.name),
          SizedBox(height: size.height * 0.02),
          buildFormField(controller: _transactionAmountController, hintText: "Amount", keyboardType: TextInputType.number),
          SizedBox(height: size.height * 0.02),
          buildFormField(controller: _transactionTypeController, hintText: "Type", keyboardType: TextInputType.text),
          SizedBox(height: size.height * 0.04),
          StatefulBuilder(
            builder: (context, _setState) => CheckboxListTile(
              title: Text("Is Income"),
              value: _isIncome,
              activeColor: Colors.black,
              onChanged: (value) {
                _setState(() {
                  _isIncome = value!;
                });
              },
            ),
          ),
          SizedBox(height: size.height * 0.04),
          MaterialButton(
            onPressed: () {
              Transaction _newTransaction = Transaction(
                amount: double.parse(_transactionAmountController.text),
                dateAdded: DateTime.now(),
                id: (Random().nextDouble() + DateTime.now().millisecondsSinceEpoch).toString(),
                isIncome: _isIncome,
                name: _transactionNameController.text,
                type: _transactionTypeController.text,
              );
              _dataController.addTransaction(_newTransaction, context);
              //reseters
              _transactionNameController.clear();
              _transactionAmountController.clear();
              _transactionTypeController.clear();
              setState(() {
                _isIncome = true;
              });
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
            minWidth: double.infinity,
            height: 50.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            color: Colors.black,
            child: Text("Add", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: size.height * 0.1),
        ],
      ),
    );
  }

  TextFormField buildFormField({required TextEditingController controller, required String hintText, required TextInputType keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      cursorColor: Colors.black,
      style: TextStyle(fontSize: 22.0),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(0xffdedede))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(0xffdedede))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(0xffdedede))),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
      ),
    );
  }

  Widget buildBottomNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: _bottomNavValue,
      elevation: 0.0,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (value) {
        setState(() {
          _bottomNavValue = value;
        });
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.mode), label: "Mode"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Chart"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }

  Widget buildHome(Size size, List<Widget> homeContent) {
    return homeContent[_groupValue];
  }

  Widget buildIntro(Size size) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.04),
            Text("Hi", style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.w600)),
            SizedBox(height: size.height * 0.04),
            buildFormField(controller: _usernameController, hintText: "Username", keyboardType: TextInputType.name),
            SizedBox(height: size.height * 0.02),
            buildFormField(controller: _currentBalanceController, hintText: "Current balance", keyboardType: TextInputType.number),
            SizedBox(height: size.height * 0.06),
            MaterialButton(
              onPressed: () {
                User _newUser = User(
                  id: (Random().nextDouble() + DateTime.now().millisecondsSinceEpoch).toString(),
                  name: _usernameController.text,
                  currentBalance: double.parse(_currentBalanceController.text),
                );
                _dataController.addUser(_newUser);
              },
              minWidth: double.infinity,
              height: 50.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              color: Colors.black,
              child: Text("Continue", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({required Size size, required String name, amount, type, createdDate, required bool isIncome, required int index, required bool isAll}) {
    TextStyle _style = TextStyle(color: Colors.white, fontSize: 18.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
      child: InkWell(
        onLongPress: () {
          isAll
              ? showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Remove"),
                    content: Text("Remove this Transaction?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("cancel")),
                      TextButton(
                          onPressed: () {
                            _dataController.removeTransaction(_dataController.transactions[index - 1]);
                            Navigator.of(context).pop();
                          },
                          child: Text("confirm")),
                    ],
                  ),
                )
              : ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                        "Can't delete in here",
                        style: TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.white),
                );
        },
        child: Container(
          height: size.height * 0.15,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isIncome ? Color(0xff57837B) : Color(0xff810000),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(2, 9), blurRadius: 10.0)],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: isIncome ? Icon(Icons.link, size: 42.0, color: Colors.white) : Icon(Icons.money, size: 42.0, color: Colors.white),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: _style.copyWith(fontWeight: FontWeight.bold)),
                            Text(amount, style: _style.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Is Expense", style: _style.copyWith(fontSize: 14.0)),
                            isIncome == true ? Icon(Icons.check_box_outline_blank, size: 18.0) : Icon(Icons.check_box, size: 18.0),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Type", style: _style.copyWith(fontSize: 14.0)),
                            Text(type, style: _style.copyWith(fontSize: 14.0)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Date", style: _style.copyWith(fontSize: 14.0)),
                            Text(DateFormat('yMMMEd').format(DateTime.parse(createdDate)), style: _style.copyWith(fontSize: 14.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAll(Size size) {
    return GetBuilder<DataController>(
      builder: (controller) => controller.currentUser.name == ""
          ? buildIntro(size)
          : SafeArea(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: controller.transactions.length + 1,
                itemBuilder: (context, index) {
                  print((controller.transactions.length).toString() + " items found in the db");
                  if (index == 0) {
                    return Column(
                      children: [
                        SizedBox(height: size.height * 0.02),
                        buildSegmentedSlider(),
                        buildCurrentBalance(size),
                        SizedBox(height: size.height * 0.04),
                      ],
                    );
                  }
                  if (controller.transactions.length == 0) {
                    return Icon(Icons.no_accounts, size: 28.0);
                  } else {
                    return Padding(
                      padding: index == controller.transactions.length ? const EdgeInsets.only(bottom: 60.0) : const EdgeInsets.all(0),
                      child: buildCard(
                        isAll: true,
                        index: index,
                        size: size,
                        name: controller.transactions[index - 1].name,
                        amount: controller.transactions[index - 1].amount.toString(),
                        type: controller.transactions[index - 1].type,
                        isIncome: controller.transactions[index - 1].isIncome,
                        createdDate: controller.transactions[index - 1].dateAdded.toString(),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  Widget buildIncome(Size size) {
    return GetBuilder<DataController>(
      builder: (controller) => controller.currentUser.name == ""
          ? buildIntro(size)
          : SafeArea(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: controller.incomeTransactions.length + 1,
                itemBuilder: (context, index) {
                  print((controller.incomeTransactions.length).toString() + " items found in the db");
                  if (index == 0) {
                    return Column(
                      children: [
                        SizedBox(height: size.height * 0.02),
                        buildSegmentedSlider(),
                        buildCurrentBalance(size),
                        SizedBox(height: size.height * 0.04),
                      ],
                    );
                  }
                  if (controller.incomeTransactions.length == 0) {
                    return Icon(Icons.no_accounts, size: 28.0);
                  } else {
                    return Padding(
                      padding: index == controller.incomeTransactions.length ? const EdgeInsets.only(bottom: 60.0) : const EdgeInsets.all(0),
                      child: buildCard(
                        isAll: false,
                        index: index,
                        size: size,
                        name: controller.incomeTransactions[index - 1].name,
                        amount: controller.incomeTransactions[index - 1].amount.toString(),
                        type: controller.incomeTransactions[index - 1].type,
                        isIncome: controller.incomeTransactions[index - 1].isIncome,
                        createdDate: controller.incomeTransactions[index - 1].dateAdded.toString(),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  Widget buildExpenses(Size size) {
    return GetBuilder<DataController>(
      builder: (controller) => controller.currentUser.name == ""
          ? buildIntro(size)
          : SafeArea(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: controller.expenseTransactions.length + 1,
                itemBuilder: (context, index) {
                  print((controller.expenseTransactions.length).toString() + " items found in the db");
                  if (index == 0) {
                    return Column(
                      children: [
                        SizedBox(height: size.height * 0.02),
                        buildSegmentedSlider(),
                        buildCurrentBalance(size),
                        SizedBox(height: size.height * 0.04),
                      ],
                    );
                  }
                  if (controller.expenseTransactions.length == 0) {
                    return Icon(Icons.no_accounts, size: 28.0);
                  } else {
                    return Padding(
                      padding: index == controller.expenseTransactions.length ? const EdgeInsets.only(bottom: 60.0) : const EdgeInsets.all(0),
                      child: buildCard(
                        isAll: false,
                        index: index,
                        size: size,
                        name: controller.expenseTransactions[index - 1].name,
                        amount: controller.expenseTransactions[index - 1].amount.toString(),
                        type: controller.expenseTransactions[index - 1].type,
                        isIncome: controller.expenseTransactions[index - 1].isIncome,
                        createdDate: controller.expenseTransactions[index - 1].dateAdded.toString(),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  Widget buildCurrentBalance(Size size) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.04),
          GetBuilder<DataController>(
            builder: (controller) => Text(
              'Hi ${controller.currentUser.name} ',
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Current balance',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.teal),
            ],
          ),
          // SizedBox(height: size.height * 0.02),
          GetBuilder<DataController>(
            builder: (controller) => Text(
              '${controller.currentUser.currentBalance} ' + "Birr",
              style: TextStyle(fontSize: 32.0),
            ),
          ),
        ],
      ),
    );
  }

  CupertinoSlidingSegmentedControl<int> buildSegmentedSlider() {
    return CupertinoSlidingSegmentedControl<int>(
      thumbColor: Colors.black,
      groupValue: _groupValue,
      children: {
        0: buildSegment(groupValue: _groupValue, label: "All", itemIndex: 0),
        1: buildSegment(groupValue: _groupValue, label: "Income", itemIndex: 1),
        2: buildSegment(groupValue: _groupValue, label: "Expenses", itemIndex: 2),
      },
      onValueChanged: (value) {
        print(value);
        setState(() {
          this._groupValue = value!;
        });
      },
    );
  }

  Container buildSegment({required int groupValue, required String label, required int itemIndex}) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(),
      child: Text(
        label,
        style: TextStyle(
          color: groupValue == itemIndex ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
