import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CreditRiskApp());
}

class CreditRiskApp extends StatelessWidget {
  const CreditRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kredi Risk Skoru',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0D47A1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0D47A1), foregroundColor: Colors.white, centerTitle: true),
      ),
      home: const RiskHomePage(),
    );
  }
}