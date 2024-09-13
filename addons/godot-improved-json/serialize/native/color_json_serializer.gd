extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_COLOR


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Color, "instance not of type Color")
	return {
		"r": instance.r,
		"g": instance.g,
		"b": instance.b,
		"a": instance.a,
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["r"] is float, "r is not a float")
	assert(serialized["g"] is float, "b is not a float")
	assert(serialized["b"] is float, "b is not a float")
	assert(serialized["a"] is float, "a is not a float")
	var color: Color = Color()
	color.r = serialized["r"]
	color.g = serialized["g"]
	color.b = serialized["b"]
	color.a = serialized["a"]
	return color
