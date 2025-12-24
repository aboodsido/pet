import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/app_constants.dart';
import '../features/transactions/data/models/transaction_model.dart';
import 'services/service_locator.dart' as di;

class AppBootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>(AppConstants.transactionBox);
    await Hive.openBox(AppConstants.settingsBox);

    await di.init();
    await dotenv.load(fileName: ".env");
    await EasyLocalization.ensureInitialized();
  }

  static Widget withLocalization(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: child,
    );
  }
}
