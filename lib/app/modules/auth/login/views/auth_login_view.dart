import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fortune_fiesta/app/data/values/strings.dart';
import 'package:fortune_fiesta/app/modules/auth/login/controllers/auth_login_controller.dart';
import 'package:fortune_fiesta/widgets/buttons/primary_filled_button.dart';
import 'package:fortune_fiesta/widgets/text_field/custom_text_field.dart';

class AuthLoginView extends GetView<AuthLoginController> {
  const AuthLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomTextField(
                  wrapper: controller.mobileWrapper,
                  hintText: Strings.mobileNumber,
                  maxLength: 10,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 8.0),
                PrimaryFilledButton(
                  text: Strings.getOTP,
                  onTap: controller.sendOTP,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
