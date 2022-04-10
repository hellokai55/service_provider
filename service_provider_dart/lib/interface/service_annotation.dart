/// 用于实现和接口的关联 impl -> interface
class ServiceBindAnnotation {
  final Type service;
  const ServiceBindAnnotation(this.service);
}

/// 统一的服务提供者
class ServiceProviderAnnotation {
  const ServiceProviderAnnotation();
}
