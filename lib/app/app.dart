import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class GoodsManagementApp extends StatelessWidget {
  const GoodsManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BSG — Goods Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
