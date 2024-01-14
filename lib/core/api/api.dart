import 'package:dio/dio.dart';

import 'package:token_master/core/api/abstract_api.dart';
import 'model.dart';

class Api extends AbstractApi {
  final Dio dio = Dio();

  @override
  Future<String> login(String username, String password, String? code, TypeAuth typeAuth) async {
    var userAgent = typeAuth == TypeAuth.Me ? UserAgent.Me : typeAuth == TypeAuth.iPhone ? UserAgent.iPhone : UserAgent.Android;
    var headers = {
      'User-Agent': userAgent.toString(),
    };

    var params = {
      "grant_type": "password",
      "client_id": typeAuth == TypeAuth.Me ? "6146827" : typeAuth == TypeAuth.iPhone ? "3140623" : "2274003",
      "client_secret": typeAuth == TypeAuth.Me ? "qVxWRF1CwHERuIrKBnqe" : typeAuth == TypeAuth.iPhone ? "VeWdmVclDCtn6ihuP1nt" : "hHbZxrka2uZ6jB1inYsH",
      "username": username,
      "password": password,
      "v": "5.207",
      "2fa_supported": "1",
      "force_sms": "1",
      "${code == '' ? 'c' : ''}code": code,
    };

    final response = await dio.get(
      'https://oauth.vk.com/token',
      queryParameters: params,
      options: Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType:ResponseType.json,
        headers: headers,
      ),
    );
    final data = response.data;
    if (data.containsKey("validation_sid")) {
      await validatePhone(data['validation_sid']);
      return 'code';
    } else if (data.containsKey("access_token")) {
      return data['access_token'];
    } else if (data.containsKey("error") && data['error'] == 'need_captcha') {
      return 'captcha';
    } else if (data.containsKey("error_description")) {
      return data['error_description'];
    } else {
      throw Exception(data);
    }
  }

  @override
  Future<void> validatePhone(String validationSid) async {
    await dio.get(
      'https://api.vk.com/method/auth.validatePhone',
      queryParameters: {
        "sid": validationSid,
        "v": "5.207",
      },
    );
  }
}
