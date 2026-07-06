import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/app_binding.dart';
import 'package:fortune_fiesta/app/data/values/constants.dart';
import 'package:fortune_fiesta/app/data/values/env.dart';
import 'package:fortune_fiesta/app/routes/app_pages.dart';
import 'package:fortune_fiesta/app/theme/premium_theme.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Env.title,
      navigatorKey: GlobalKeys.navigationKey,
      debugShowCheckedModeBanner: false,
      theme: PremiumTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.premiumHome,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      initialBinding: AppBinding(),
    );
  }
}
