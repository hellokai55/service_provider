import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';

import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import 'each_service_info.dart';

class ServiceAnnotationHelper {
  factory ServiceAnnotationHelper.getInstace() => _instance;

  static late final ServiceAnnotationHelper _instance =
      ServiceAnnotationHelper._internal();

  // 保存每一个注解对象
  Map<String, EachServiceInfo> eachServiceInfoMaps = HashMap();

  //导入依赖
  Set<Directive> allImportSet = SplayTreeSet();

  ServiceAnnotationHelper._internal() {
    allImportSet.add(Directive.import(
        'package:service_provider/interface/service_interface.dart'));
  }

  Future<void> collect(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element.kind == ElementKind.CLASS) {
      final interfaceElement = annotation.read("service").typeValue.element;
      if (interfaceElement == null) {
        return;
      }
      String implStr = element.declaration!.displayName;
      String interfaceStr = interfaceElement.displayName;
      final List<String> importList = [];
      String implPackagePath = buildStep.inputId.uri.toString();
      importList.add(implPackagePath);
      importList.add(interfaceElement.librarySource!.uri.toString());
      // 每一个服务对应一个实例
      EachServiceInfo info = EachServiceInfo(importList, interfaceStr, implStr);
      if (!eachServiceInfoMaps.containsKey(interfaceStr)) {
        eachServiceInfoMaps[interfaceStr] = info;
      } else {
        throw Exception("""
================================service.erro============================================
You have registered two identical services, please check for errors!!!!,service:$interfaceStr
=============================================================================================
            """);
      }
    }
  }

  String write(BuildStep buildStep) {
    DartEmitter emitter = DartEmitter.scoped();
    var library = Library((b) {
      b.body.addAll([
        //生成类
        Class((builder) {
          builder.name = "ServiceProviderInternal";
          builder.fields.addAll([
            Field((fieldBuilder) {
              fieldBuilder.name = "_cache";
              fieldBuilder.type = refer("Map<Type, IService>");
              fieldBuilder.modifier = FieldModifier.var$;
              fieldBuilder.assignment = const Code("{}");
              fieldBuilder.modifier = FieldModifier.final$;
            })
          ]);
          builder.methods.addAll(
            //生成方法
            [
              Method((methodBuilder) {
                methodBuilder.name = "getService";
                methodBuilder.body = _generatorGetService(eachServiceInfoMaps);
                methodBuilder.types.add(refer('T extends IService'));
                methodBuilder.returns = refer('T');
              }),
              Method((methodBuilder) {
                methodBuilder.name = "_getService";
                methodBuilder.body = _generatorInnerGetService();
                methodBuilder.types.add(refer('T extends IService'));
                methodBuilder.requiredParameters.add(Parameter((builder) {
                  builder.name = "impl";
                  builder.type = refer('IService');
                }));
                methodBuilder.returns = refer('T');
              })
            ],
          );
        }),
      ]);
      //导入引用
      b.directives.clear();
      b.directives.addAll(allImportSet);
    });
    return DartFormatter().format('${library.accept(emitter)}');
  }

  Code _generatorGetService(Map<String, EachServiceInfo> maps) {
    final blocks = <Code>[];
    blocks.add(const Code("switch (T) {"));
    maps.forEach((key, value) {
      blocks.add(Code("case ${value.interfaceStr}:"));
      blocks.add(Code("return _getService<T>(${value.implStr}());"));
      allImportSet.addAll(value.importList.map((e) => Directive.import(e)));
    });
    blocks.add(const Code("default:"));
    blocks.add(const Code(
        "throw Exception(\"ServiceProviderInternal not find service!!!!!\");"));
    blocks.add(const Code("}"));
    return Block.of(blocks);
  }

  Code _generatorInnerGetService() {
    final blocks = <Code>[];
    blocks.add(const Code("if (!_cache.containsKey(T)) {"));
    blocks.add(const Code("_cache[T] = impl;"));
    blocks.add(const Code("impl.init();"));
    blocks.add(const Code("}"));
    blocks.add(const Code("return _cache[T] as T;"));
    return Block.of(blocks);
  }
}
