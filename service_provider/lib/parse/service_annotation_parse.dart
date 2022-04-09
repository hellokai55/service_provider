import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import '../interface/service_annotation.dart';
import 'service_parse_helper.dart';

class ServiceFinder extends GeneratorForAnnotation<ServiceBindAnnotation> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    ServiceAnnotationHelper.getInstace()
        .collect(element, annotation, buildStep);
  }
}

/// 服务提供
class ServiceProvider
    extends GeneratorForAnnotation<ServiceProviderAnnotation> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return ServiceAnnotationHelper.getInstace().write(buildStep);
  }
}
