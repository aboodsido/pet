import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/logic/navigation_cubit.dart';
import 'core/services/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/ai_advisor/logic/ai_advisor_cubit.dart';
import 'features/navigation/ui/main_navigation_screen.dart';
import 'features/onboarding/ui/onboarding_view.dart';
import 'features/settings/logic/theme_cubit.dart';
import 'features/transactions/logic/transaction_cubit.dart';

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
            home: const AppEntryPoint(),
          );
        },
      ),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final box = Hive.box(AppConstants.settingsBox);
    final completed =
        box.get(AppConstants.onboardingCompletedKey, defaultValue: false) ==
        true;
    if (mounted) {
      setState(() => _hasCompletedOnboarding = completed);
    }
  }

  Future<void> _completeOnboarding() async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put(AppConstants.onboardingCompletedKey, true);
    if (mounted) {
      setState(() => _hasCompletedOnboarding = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCompletedOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasCompletedOnboarding!) {
      return const MainNavigationScreen();
    }

    return OnboardingView(onFinished: _completeOnboarding);
  }
}
