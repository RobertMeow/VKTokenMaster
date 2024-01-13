import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:token_master/core/api/abstract_api.dart';
import 'model.dart';

class Api extends AbstractApi {
  final http.Client client = http.Client();

  @override
  Future<String> login(String username, String password, String? code, TypeAuth typeAuth) async {
    var userAgent = typeAuth == TypeAuth.Me ? UserAgent.Me : typeAuth == TypeAuth.iPhone ? UserAgent.iPhone : UserAgent.Android;
    var headers = {'User-Agent': userAgent.toString()};

    var uri = Uri.https('oauth.vk.com', '/token', {
      "grant_type": "password",
      "client_id": typeAuth == TypeAuth.Me ? "6146827" : typeAuth == TypeAuth.iPhone ? "3140623" : "2274003",
      "client_secret": typeAuth == TypeAuth.Me ? "qVxWRF1CwHERuIrKBnqe" : typeAuth == TypeAuth.iPhone ? "VeWdmVclDCtn6ihuP1nt" : "hHbZxrka2uZ6jB1inYsH",
      "username": username,
      "password": password,
      "v": "5.207",
      "2fa_supported": "1",
      "force_sms": "1",
      "${code == '' ? 'c' : ''}code": code,
    });
    var response = await client.get(uri, headers: headers);
    var data = json.decode(response.body);

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
    var uri = Uri.https('api.vk.com', '/method/auth.validatePhone', {
      "sid": validationSid,
      "v": "5.207",
    });
    await client.get(uri);
  }
}
