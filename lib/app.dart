import 'package:flutter/material.dart';

import 'views/planner_home_view.dart';

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planner Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF247A73),
          secondary: Color(0xFFFFC07A),
          surface: Color(0xFFF7F4EF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1ECE6),
        useMaterial3: true,
      ),
      home: const PlannerHomeView(),
    );
  }
}
