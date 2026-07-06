import 'package:get/get.dart';

import '../modules/auth/login/bindings/auth_login_binding.dart';
import '../modules/auth/login/views/auth_login_view.dart';
import '../modules/auth/signup/bindings/auth_signup_binding.dart';
import '../modules/auth/signup/views/auth_signup_view.dart';
import '../modules/auth/verify-otp/bindings/auth_verify_otp_binding.dart';
import '../modules/auth/verify-otp/views/auth_verify_otp_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/premium_home/bindings/premium_home_binding.dart';
import '../modules/premium_home/views/premium_home_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.authLogin,
      page: () => const AuthLoginView(),
      binding: AuthLoginBinding(),
    ),
    GetPage(
      name: Routes.authVerifyOTP,
      page: () => const AuthVerifyOtpView(),
      binding: AuthVerifyOtpBinding(),
    ),
    GetPage(
      name: Routes.authSignup,
      page: () => const AuthSignupView(),
      binding: AuthSignupBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.premiumHome,
      page: () => const PremiumHomeView(),
      binding: PremiumHomeBinding(),
    ),
  ];
}
