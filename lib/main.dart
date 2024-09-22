import 'package:flutter/material.dart';
import 'exchange_rate_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exchange Rate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExchangeRateList(),
    );
  }
}