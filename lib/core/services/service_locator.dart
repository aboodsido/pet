import 'package:get_it/get_it.dart';

import '../../features/ai_advisor/logic/ai_advisor_cubit.dart';
import '../../features/settings/logic/theme_cubit.dart';
import '../../features/transactions/data/repositories/transaction_repository.dart';
import '../../features/transactions/logic/transaction_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(),
  );

  // Cubits
  sl.registerFactory<TransactionCubit>(() => TransactionCubit(sl()));
  sl.registerFactory<AiAdvisorCubit>(() => AiAdvisorCubit(sl()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
}
