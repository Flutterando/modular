import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:flutter_modular/src/annotations/annotations.dart';
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
    List<Element> listElements = element.library.topLevelElements.toList();
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

    // print(visitor2.params);
    _write(
        "final ${element.displayName[0].toLowerCase()}${element.displayName.substring(1)} = BindInject((i) => ${element.displayName}(${visitor.params.join(', ')}), singleton: $singleton, lazy: $lazy,);");
    return _buffer.toString();
  }
}

class ModelVisitor extends SimpleElementVisitor {
  DartType className;
  List<String> params = [];
  bool isAnnotation = false;

  ModelVisitor();
  //ModelVisitor visitor = ModelVisitor();

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
    isAnnotation = element.parameters.firstWhere((param) {
          if (param.metadata.length > 0) {
            return param.metadata.firstWhere((param) {
                  return param.element.displayName == "Data" ||
                      param.element.displayName == "Param";
                }, orElse: () => null) !=
                null;
          }
          return false;
        }, orElse: () => null) !=
        null;
    writeParams(element.parameters);
  }

  writeParams(List<ParameterElement> parameters) {
    params = parameters.map((param) {
      if (param.metadata.length > 0) {
        String arg;
        for (var meta in param.metadata) {
          if (meta.element.displayName == 'Param') {
            arg = _normalizeParam(param);
          } else if (meta.element.displayName == 'Data') {
            arg = _normalizeData(param);
          }
        }
        return arg == null ? _normalize(param) : arg;
      } else {
        return _normalize(param);
      }
    }).toList();
  }

  String _normalize(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i<${param.type}>()";
    } else {
      return "i<${param.type}>()";
    }
  }

  String _normalizeParam(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i.args.params['${param.name}']";
    } else {
      return "i.args.params['${param.name}']";
    }
  }

  String _normalizeData(ParameterElement param) {
    if (param.isNamed) {
      return "${param.name}: i.args.data";
    } else {
      return "i.args.data";
    }
  }

  @override
  visitClassElement(ClassElement element) {
    print(element.name);
  }
}
