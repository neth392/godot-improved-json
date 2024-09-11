extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_TRANSFORM2D


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Transform2D, "instance not of type Transform2D")
	assert(impl != null, "impl is null")
	assert(impl._vector2 != null, "impl._vector2 is null")
	return {
		"o": impl._vector2._serialize(instance.origin, impl),
		"x": impl._vector2._serialize(instance.x, impl),
		"y": impl._vector2._serialize(instance.y, impl),
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["o"] is Dictionary, "o is not a Dictionary")
	assert(serialized["x"] is Dictionary, "x is not a Dictionary")
	assert(serialized["y"] is Dictionary, "y is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector2 != null, "impl._vector2 is null")
	
	var transform2d: Transform2D = Transform2D()
	transform2d.origin = impl._vector2._deserialize(serialized["o"], impl)
	transform2d.x = impl._vector2._deserialize(serialized["x"], impl)
	transform2d.y = impl._vector2._deserialize(serialized["y"], impl)
	return transform2d
