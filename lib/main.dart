import 'package:flutter/material.dart';
import 'package:simple_admob_app/presentation/home_page.dart';

void main() {
  runApp(AppWidget());
}

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admob Monetization - Banner & Interstitial Ads',
      home: HomePage(),
    );
  }
}