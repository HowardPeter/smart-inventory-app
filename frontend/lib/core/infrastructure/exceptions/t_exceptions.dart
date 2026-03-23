import 'package:dio/dio.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:get/get.dart';

class TExceptions {
  static Map<String, String> getErrorMessage(dynamic e) {
    String title = TTexts.errorUnknownTitle.tr;
    String message = TTexts.errorUnknownMessage.tr;

    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          title = TTexts.errorTimeoutTitle.tr;
          message = TTexts.errorTimeoutMessage.tr;
          break;
        case DioExceptionType.connectionError:
          title = TTexts.netErrorTitle.tr;
          message = TTexts.netErrorDescription.tr;
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 404) {
            title = TTexts.errorNotFoundTitle.tr;
            message = TTexts.errorNotFoundMessage.tr;
          } else if (statusCode != null && statusCode >= 500) {
            title = TTexts.errorServerTitle.tr;
            message = TTexts.errorServerMessage.tr;
          }
          break;
        default:
          break;
      }
    }
    return {'title': title, 'message': message};
  }
}
