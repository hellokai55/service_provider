import 'package:service_provider_dart/interface/service_interface.dart';

abstract class ILoginService implements IService {
  void login();
  void getUserInfo();
}
