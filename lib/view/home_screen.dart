import 'package:allowance/model/transaction.dart';
import 'package:allowance/model/user.dart';
import 'package:allowance/utils/boxes.dart';
import 'package:allowance/view/chart_screen.dart';
import 'package:allowance/view/edit_screen.dart';
import 'package:allowance/view/setting_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _groupValue = 0;
  int _bottomNavValue = 0;
  bool isExpense = true;
  bool isIntro = false;

  final _data = GetStorage();

  TextEditingController _transactionNameController = TextEditingController();
  TextEditingController _transactionAmountController = TextEditingController();
  TextEditingController _transactionTypeController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _currentBalanceController = TextEditingController();

  @override
  void dispose() {
    Hive.box('user').close();

    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      Boxes.getTransactions().values.toList().cast<User>().length == 0 ? isIntro = true : isIntro = false;
    });
    super.initState();
  }

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
    return Scaffold(
      body: contents[_bottomNavValue],
      bottomNavigationBar: isIntro ? null : buildBottomNavBar(),
      floatingActionButton: isIntro
          ? null
          : FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
                  context: context,
                  builder: (context) => buildSheet(size),
                );
              },
              backgroundColor: Colors.black,
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget buildSheet(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
          buildFormField(controller: _transactionNameController, hintText: "Name"),
          SizedBox(height: size.height * 0.02),
          buildFormField(controller: _transactionAmountController, hintText: "Amount"),
          SizedBox(height: size.height * 0.02),
          buildFormField(controller: _transactionTypeController, hintText: "Type"),
          SizedBox(height: size.height * 0.04),
          CheckboxListTile(
            title: Text("Is Expense"),
            value: isExpense,
            activeColor: Colors.black,
            onChanged: (value) {
              setState(() {
                isExpense = value!;
              });
            },
          ),
          SizedBox(height: size.height * 0.04),
          MaterialButton(
            onPressed: () {
              //TODO: fix stuff here
              final _transaction = new Transaction(
                name: _transactionNameController.text.trim(),
                amount: double.parse(_transactionAmountController.text),
                type: _transactionTypeController.text.trim(),
                createdDate: DateTime.now(),
                isExpense: isExpense,
              );

              final user = User()
                ..userName = _data.read('userName')
                ..currentBalance = double.parse(_data.read('currentBalance'))
                ..transactionList = [_transaction];

              final box = Boxes.getTransactions();

              box.add(user);

              //reseters
              _transactionNameController.clear();
              _transactionAmountController.clear();
              _transactionTypeController.clear();
              setState(() {
                isExpense = true;
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

  TextFormField buildFormField({required TextEditingController controller, required String hintText}) {
    return TextFormField(
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
            buildFormField(controller: _usernameController, hintText: "Username"),
            SizedBox(height: size.height * 0.02),
            buildFormField(controller: _currentBalanceController, hintText: "Current balance"),
            SizedBox(height: size.height * 0.06),
            MaterialButton(
              onPressed: () {
                _data.write('userName', _usernameController.text.trim());
                _data.write('currentBalance', _currentBalanceController.text.trim());
                final newUser = User()
                  ..userName = _usernameController.text.trim()
                  ..currentBalance = double.parse(_currentBalanceController.text.trim())
                  ..transactionList = [];

                final box = Boxes.getTransactions();

                setState(() {
                  box.add(newUser);
                  isIntro = false;
                });
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

  Widget buildAll(Size size) {
    return Boxes.getTransactions().values.toList().cast<User>().length == 0
        ? buildIntro(size)
        : SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                width: double.infinity,
                height: size.height,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.02),
                    buildSegmentedSlider(),
                    buildCurrentBalance(size),
                    SizedBox(height: size.height * 0.04),
                    Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: Boxes.getTransactions().values.toList().cast<User>().length - 1,
                        itemBuilder: (context, index) {
                          final box = Boxes.getTransactions();
                          final values = box.values.toList().cast<User>();
                          print(values.length.toString() + " items found in the db");
                          if (values.length == 1) {
                            return Icon(Icons.no_accounts, size: 28.0);
                          } else {
                            return buildCard(
                              size: size,
                              name: values[index + 1].transactionList[0].name,
                              amount: values[index + 1].transactionList[0].amount.toString(),
                              type: values[index + 1].transactionList[0].type,
                              isExpense: values[index + 1].transactionList[0].isExpense,
                              createdDate: values[index + 1].transactionList[0].createdDate.toString(),
                            );
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildCard({required Size size, required String name, amount, type, createdDate, required bool isExpense}) {
    TextStyle _style = TextStyle(color: Colors.white, fontSize: 18.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
      height: size.height * 0.15,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isExpense ? Color(0xff810000) : Color(0xff57837B),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(color: Colors.black54, offset: Offset(2, 9), blurRadius: 10.0)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: isExpense ? Icon(Icons.money, size: 42.0, color: Colors.white) : Icon(Icons.link, size: 42.0, color: Colors.white),
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
                        isExpense == true ? Icon(Icons.check_box, size: 18.0) : Icon(Icons.check_box_outline_blank, size: 18.0),
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
    );
  }

  Widget buildIncome(Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              buildSegmentedSlider(),
              buildCurrentBalance(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpenses(Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              buildSegmentedSlider(),
              buildCurrentBalance(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCurrentBalance(Size size) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.04),
          Text(
            'Hi ${_data.read('userName')} ',
            style: TextStyle(fontSize: 22.0),
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
          Text(
            '${_data.read('currentBalance')} ' + "Birr",
            style: TextStyle(fontSize: 32.0),
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
