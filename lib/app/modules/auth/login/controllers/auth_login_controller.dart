import 'package:get/get.dart';
import 'package:fortune_fiesta/app/data/models/dto/response.dart';
import 'package:fortune_fiesta/app/data/models/request/auth_request.dart';
import 'package:fortune_fiesta/app/data/repository/user_repository.dart';
import 'package:fortune_fiesta/app/data/values/strings.dart';
import 'package:fortune_fiesta/app/routes/app_pages.dart';
import 'package:fortune_fiesta/base/base_controller.dart';
import 'package:fortune_fiesta/utils/helper/text_field_wrapper.dart';
import 'package:fortune_fiesta/utils/helper/validators.dart';
import 'package:fortune_fiesta/utils/loading/loading_utils.dart';

class AuthLoginController extends BaseController<UserRepository> {
  final mobileWrapper = TextFieldWrapper();

  sendOTP() async {
    String mobile = mobileWrapper.controller.text.trim();
    if (mobile.isValidPhone()) {
      mobileWrapper.errorText = Strings.empty;
    } else {
      mobileWrapper.errorText = ErrorMessages.invalidPhone;
      return;
    }

    LoadingUtils.showLoader();
    RepoResponse<bool> response =
        await repository.sendOTP(SendOTPRequest(phone: mobile));
    LoadingUtils.hideLoader();

    if (response.data ?? false) {
      Get.toNamed(Routes.AUTH_VERIFY_OTP, arguments: mobile);
    } else {
      mobileWrapper.errorText = response.error?.message ?? "";
    }
  }
}
