import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'modular_codegen.dart';

Builder injection(BuilderOptions options) =>
    SharedPartBuilder([InjectionGenerator()], 'inject');
