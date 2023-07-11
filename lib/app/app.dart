import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fortune_fiesta/app/app_binding.dart';
import 'package:fortune_fiesta/app/data/values/constants.dart';
import 'package:fortune_fiesta/app/data/values/env.dart';
import 'package:fortune_fiesta/app/routes/app_pages.dart';
import 'package:fortune_fiesta/app/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Env.title,
      navigatorKey: GlobalKeys.navigationKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: Routes.HOME,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      initialBinding: AppBinding(),
    );
  }
}
