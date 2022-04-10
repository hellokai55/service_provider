

import 'package:service_provider_dart/interface/service_annotation.dart';

import 'login_service.service.find.dart';

/// 登录实现
@ServiceBindAnnotation(ILoginService)
class LoginService implements ILoginService {
  @override
  void init() {}

  @override
  void getUserInfo() {
    print('getUserInfo');
  }

  @override
  void login() {
    print('login');
  }
}
