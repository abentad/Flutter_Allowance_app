import 'package:allowance/controller/theme_controller.dart';
import 'package:allowance/model/transaction.dart';
import 'package:allowance/model/user.dart';
import 'package:allowance/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Get.put(ThemeController());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Get.find<ThemeController>().statusBarColor,
    statusBarIconBrightness: Get.find<ThemeController>().statusBarIconBrghtness,
  ));
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<User>('user');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Allowance',
      theme: Get.find<ThemeController>().defaultThemeData,
      home: HomeScreen(),
    );
  }
}
