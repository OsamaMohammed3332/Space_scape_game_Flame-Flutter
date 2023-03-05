import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:space_scape/screens/main_menu.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(scaffoldBackgroundColor: Colors.black),
    home: const MainMenu(),
  ));
}
