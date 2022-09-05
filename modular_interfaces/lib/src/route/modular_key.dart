import 'package:meta/meta.dart';

/// Object used as a reference to find a ModularRoute in the RouteContext tree.
@immutable
class ModularKey {
  /// Schema for the Modular key
  final String schema;

  /// Name for the Modular key
  final String name;

  /// [ModularKey] constructor
  const ModularKey({required this.name, this.schema = ''});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModularKey && other.schema == schema && other.name == name;
  }

  @override
  int get hashCode => schema.hashCode ^ name.hashCode;

  ///Copy the [copyWith] object into another memory reference
  ModularKey copyWith({
    String? schema,
    String? name,
  }) {
    return ModularKey(
      schema: schema ?? this.schema,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'ModularKey(schema: $schema, name: $name)';
}
