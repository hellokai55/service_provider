import 'package:service_provider/interface/service_annotation.dart';
import 'package:service_provider/interface/service_interface.dart';

import 'service_provider.service.dart';

@ServiceProviderAnnotation()
class ServiceProvider {
  static final ServiceProviderInternal _internal = ServiceProviderInternal();
  static T getService<T extends IService>() {
    return _internal.getService<T>();
  }
}
