import 'model.dart';

abstract class AbstractApi {
  Future<String> login(String username, String password, String code, TypeAuth typeAuth);
  Future<void> validatePhone(String validationSid);
}
