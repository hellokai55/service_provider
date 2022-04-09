import 'package:service_provider/interface/service_interface.dart';

abstract class ILoginService implements IService {
  void login();
  void getUserInfo();
}
