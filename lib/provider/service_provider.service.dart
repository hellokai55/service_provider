// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: ServiceProvider
// **************************************************************************

import 'package:service_provider/interface/service_interface.dart';
import 'package:service_provider_sample/sample/login.service.service.dart';
import 'package:service_provider_sample/sample/login_service.service.find.dart';

class ServiceProviderInternal {
  final Map<Type, IService> _cache = {};

  T getService<T extends IService>() {
    switch (T) {
      case ILoginService:
        return _getService<T>(LoginService());
      default:
        throw Exception("ServiceProviderInternal not find service!!!!!");
    }
  }

  T _getService<T extends IService>(IService impl) {
    if (!_cache.containsKey(T)) {
      _cache[T] = impl;
      impl.init();
    }
    return _cache[T] as T;
  }
}
