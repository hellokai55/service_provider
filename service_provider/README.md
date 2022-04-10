## 一、背景
在做Flutter侧业务开发时，不同同学会负责不同的业务模块，也都会使用一些类似于登录，跳转等非业务的基础功能，如果不把这些功能抽象出来统一管理的话，业务之间会耦合严重，不便于后续业务的拆分和演进，基于此实现服务解耦功能，类似于`Java`中的`SPI`

## 二、如何做
服务解耦就是需要将抽象和实现分离，也就是具体的业务我们需要抽象成一个接口，具体的业务来实现这个接口，最主要的是我们暴露给业务方的需要是抽象也就是接口，隐藏我们实现类的逻辑，那么就可看出来需要解决以下两个问题：

- 抽象 → 实现，如何绑定
- 业务方如何获取

具体实现我们可以参照`Android`解决此问题的方式，可以使用注解+代码生成的方式来实现，`dart`中也提供了注解，那么以上两步的解决方案就是

绑定可以使用注解来做
业务方如何获取可以通过编译期代码生成，统一的`ServiceProvider`来提供服务
### 2.1 抽象和服务的关联
下文都以登录为例子：

我们先将服务的接口和实现分离，这个很好做：

抽象的接口：

```
/// 登录接口
abstract class ILoginService implements IService {
  void login();
  void logout();
}
 
/// 登录实现，这里使用了注解进行绑定
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
```
### 2.2 如何获取
上面说了可以通过编译期代码生成，有以下几个方式：

- 自己按照格式来字符串生成文件
- 使用`mustache4dart2`模板代码生成
- 使用`code_builder`类似于`ASM`的方式

第1种方式自己写格式处理等不好做，也没有代码相关限制，加上后期维护成本高的原因所以不选择第一种；第2中方式是闲鱼的路由框架使用的开源库，但是现在不支持空安全；所以最后选择了第3种方式，它是`flutter`官方提供的，功能强大，但是没有过多地介绍和`api`文档不够完善，只能在开发中逐渐摸索

集中的代码生成我们直接看代码：
```
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
```
类似于`Class`，`Method`，`Field`就是`code_builder`提供生成类的`api`，基本使用看注释就可以了；

根据以上分析再加上编译期注解生成，我们看一下最后生成的代码：
```
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
```
## 三、使用方式
那我作为业务方怎么用呢？

#### 3.1 别人写好了我直接用
直接使用使用ServiceProvider.getService<ILoginService>()来获取实例并调用方法即可，ILoginService换成需要的接口

#### 3.2 别人没写我自己创建
1. 创建服务接口类`ILoginService`，实现自`IService`
2. 实现具体服务类，继承自刚才的接口`ILoginService`，并且用`@ServiceBindAnnotation`注解来进行绑定
3. 通过 `flutter pub run build_runner build` 来生成代码，生成后的文件是 `service_provider.service.dart` 中，如果生成有问题可以先 `flutter pub run build_runner clean` 然后再 `flutter pub run build_runner clean`
4. 使用`ServiceProvider.getService<ILoginService>()`来获取实例并调用方法即可


#### 3.3 源码地址
源码地址，有兴趣的同学可以看看，在：https://github.com/hellokai55/service_provider
