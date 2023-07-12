import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/theme/app_colors.dart';
import 'package:fortune_fiesta/utils/helper/custom_snackbar.dart';

import 'package:fortune_fiesta/app/data/models/response/error_response.dart';
import 'package:fortune_fiesta/app/data/values/strings.dart';

class APIException implements Exception {
  final String message;

  APIException({required this.message});
}

class ExceptionHandler {
  ExceptionHandler._privateConstructor();

  static APIException handleError(Exception error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.sendTimeout:
          return APIException(message: ErrorMessages.noInternet);
        case DioExceptionType.connectionTimeout:
          return APIException(message: ErrorMessages.connectionTimeout);
        case DioExceptionType.badResponse:
          return APIException(
              message: ErrorResponse.fromJson(error.response?.data).message);
        default:
          return APIException(message: ErrorMessages.networkGeneral);
      }
    } else {
      return APIException(message: ErrorMessages.networkGeneral);
    }
  }
}

class HandleError {
  HandleError._privateConstructor();

  static handleError(APIException? error) {
    showCustomSnackbar(Strings.error,
        error?.message ?? ErrorMessages.networkGeneral, Colors.redAccent);
  }

  static void showError(String? error) {
    showCustomSnackbar(Strings.alert, error ?? ErrorMessages.networkGeneral,
        AppColors.primaryColor);
  }
}