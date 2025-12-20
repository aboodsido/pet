import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/services/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/ai_advisor/logic/ai_advisor_cubit.dart';
import 'features/ai_advisor/ui/views/ai_advisor_view.dart';
import 'features/dashboard/ui/views/dashboard_view.dart';
import 'features/settings/ui/views/settings_view.dart';
import 'features/statistics/ui/views/statistics_view.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/logic/transaction_cubit.dart';
import 'features/transactions/ui/views/transactions_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());
  await Hive.openBox<TransactionModel>(AppConstants.transactionBox);

  // Initialize Service Locator
  await di.init();

  runApp(const PetExpenseApp());
}

class PetExpenseApp extends StatelessWidget {
  const PetExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<TransactionCubit>()..loadTransactions(),
        ),
        BlocProvider(create: (context) => di.sl<AiAdvisorCubit>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const TransactionsView(),
    const StatisticsView(),
    const AiAdvisorView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            label: 'AI Advisor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
