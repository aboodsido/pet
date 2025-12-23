import 'package:get_it/get_it.dart';

import '../../features/ai_advisor/data/repositories/ai_advisor_repository.dart';
import '../../features/ai_advisor/logic/ai_advisor_cubit.dart';
import '../../features/settings/logic/theme_cubit.dart';
import '../../features/transactions/data/repositories/transaction_repository.dart';
import '../../features/transactions/logic/transaction_cubit.dart';
import '../logic/navigation_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(),
  );
  sl.registerLazySingleton<AiAdvisorRepository>(() => AiAdvisorRepository());

  sl.registerFactory<TransactionCubit>(() => TransactionCubit(sl()));
  sl.registerFactory<AiAdvisorCubit>(() => AiAdvisorCubit(sl(), sl()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<NavigationCubit>(() => NavigationCubit());
}
