import 'package:flutter/material.dart';
import 'page/map_page.dart';
import 'page/MainPage.dart';
import 'page/Baseball_page.dart';
import 'page/Swim_page.dart';
import 'page/Soccer_page.dart';
import 'page/Badminton_page.dart';
import 'page/Basketball_page.dart';
import 'page/Tennis_page.dart';
import 'page/logo_page.dart';
import 'page/lecture_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // DEBUG 태그 비활성화
      title: 'Seoul Facility Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/map': (context) => MapPage(),
        '/Main': (context) => MainPage(),
        '/Baseball': (context) => BaseballPage(),
        '/Swim': (context) => SwimPage(),
        '/Soccer': (context) => SoccerPage(),
        '/Badminton' : (context) => BadmintonPage(),
        '/Basketball' : (context) => BasketballPage(),
        '/Tennis' : (context) => TennisPage(),
        '/' : (context) => LogoPage(),
        '/lecture' : (context) => LecturePage(),

      },
    );
  }
}
