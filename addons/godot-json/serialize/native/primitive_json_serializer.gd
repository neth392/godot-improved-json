## Represents a "primitive" type that is supported by Godot's [JSON] methods, such as
## [enum Variant.TYPE_STRING], [enum Variant.TYPE_BOOL].
## Primitive types do not support [method JSONSerializer._deserialize_into].
## For the code used to test which types work with this, see primitive_json_serializer_tests.gd
class_name PrimitiveJSONSerializer extends JSONSerializer

@export var primitive_type: Variant.Type

func _init(_primitive_type: Variant.Type = TYPE_NIL) -> void:
	primitive_type = _primitive_type


func _get_id() -> Variant:
	return primitive_type


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	return instance


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	return null if serialized == null else type_convert(serialized, primitive_type)
