import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:flutter_modular_annotations/flutter_modular_annotations.dart';
import 'package:source_gen/source_gen.dart';

class InjectionGenerator extends GeneratorForAnnotation<Injectable> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final singleton = annotation.read('singleton').boolValue;
    final lazy = annotation.read('lazy').boolValue;

    final _buffer = StringBuffer();
    _write(Object o) => _buffer.write(o);
    final visitor = ModelVisitor();
    List<Element> listElements = element.library!.topLevelElements.toList();
    for (var i = listElements.length - 1; i >= 0; i--) {
      var item = listElements[i];
      item.visitChildren(visitor);

      if (visitor.isAnnotation) {
        break;
      }

      if (i == 0) {
        element.visitChildren(visitor);
        break;
      }
    }
    _write(
        "final \$${element.displayName} = BindInject((i) => ${element.displayName}(${visitor.params.join(', ')}), isSingleton: $singleton, isLazy: $lazy,);");
    return _buffer.toString();
  }
}

class ModelVisitor extends SimpleElementVisitor {
  DartType? className;
  List<String> params = [];
  bool isAnnotation = false;

  bool _isAnnotation(ConstructorElement element) {
    return element.parameters
        .map((parameter) => parameter.metadata)
        .expand((annotations) => annotations)
        .map((annotation) => annotation.element?.displayName ?? '')
        .where((displayName) =>
            ['Data', 'Param', 'QueryParam', 'Default'].contains(displayName))
        .isNotEmpty;
  }

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
    isAnnotation = _isAnnotation(element);
    writeParams(element.parameters);
  }

  writeParams(List<ParameterElement> parameters) {
    params = parameters.map((param) {
      if (param.metadata.isNotEmpty) {
        String? arg;

        for (var meta in param.metadata) {
          if (meta.element?.displayName == 'Param') {
            arg = _normalizeParam(param);
          } else if (meta.element?.displayName == 'QueryParam') {
            arg = _normalizeQueryParam(param);
          } else if (meta.element?.displayName == 'Data') {
            arg = _normalizeData(param);
          } else if (meta.element?.displayName == 'Default') {
            arg = _normalizeDefault(param);
          }
        }
        return arg ?? _normalize(param);
      } else {
        return _normalize(param);
      }
    }).toList();
  }

  String _normalize(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i<${param.type.element?.displayName}>()";
    } else {
      return "i<${param.type.element?.displayName}>()";
    }
  }

  String _normalizeParam(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i.args.params['${param.name}']";
    } else {
      return "i.args.params['${param.name}']";
    }
  }

  String _normalizeQueryParam(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i.args.queryParams['${param.name}']";
    } else {
      return "i.args.queryParams['${param.name}']";
    }
  }

  String _normalizeData(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i.args.data";
    } else {
      return "i.args.data";
    }
  }

  String _normalizeDefault(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i<${param.type}>(defaultValue: null)";
    } else {
      return "i<${param.type}>(defaultValue: null)";
    }
  }

  @override
  visitClassElement(ClassElement element) {}
}
