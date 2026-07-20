import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_verify_otp_controller.dart';

class AuthVerifyOtpView extends GetView<AuthVerifyOtpController> {
  const AuthVerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuthVerifyOtpView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AuthVerifyOtpView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
