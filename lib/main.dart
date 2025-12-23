import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/logic/navigation_cubit.dart';
import 'core/services/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/ai_advisor/logic/ai_advisor_cubit.dart';
import 'features/ai_advisor/ui/views/ai_advisor_view.dart';
import 'features/dashboard/ui/views/dashboard_view.dart';
import 'features/settings/logic/theme_cubit.dart';
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
  await Hive.openBox(AppConstants.settingsBox);

  // Initialize Service Locator
  await di.init();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const PetExpenseApp(),
    ),
  );
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
        BlocProvider(
          create: (context) => di.sl<AiAdvisorCubit>()..analyzeSpending(),
        ),
        BlocProvider(create: (context) => di.sl<ThemeCubit>()),
        BlocProvider(create: (context) => di.sl<NavigationCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'app_name'.tr(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const MainNavigationScreen(),
          );
        },
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
  final List<Widget> _screens = [
    const DashboardView(),
    const TransactionsView(),
    const StatisticsView(),
    const AiAdvisorView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          body: _screens[selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => context.read<NavigationCubit>().setIndex(index),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard),
                label: 'dashboard'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.receipt_long_outlined),
                activeIcon: const Icon(Icons.receipt_long),
                label: 'transactions'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart),
                label: 'stats'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_awesome_outlined),
                activeIcon: const Icon(Icons.auto_awesome),
                label: 'ai_advisor'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: 'settings'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }
}
