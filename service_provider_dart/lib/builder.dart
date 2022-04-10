import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import '../parse/service_annotation_parse.dart';

/// 服务发现
Builder serviceFinder(BuilderOptions options) =>
    LibraryBuilder(ServiceFinder(), generatedExtension: ".service.find.dart");

/// 服务提供
Builder serviceProvider(BuilderOptions options) =>
    LibraryBuilder(ServiceProvider(), generatedExtension: ".service.dart");
