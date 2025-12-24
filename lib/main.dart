import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/bootstrap.dart';

void main() async {
  await AppBootstrap.init();
  runApp(AppBootstrap.withLocalization(const PetExpenseApp()));
}
