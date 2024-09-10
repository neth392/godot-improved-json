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
		"r8": instance.r8,
		"g8": instance.g8,
		"b8": instance.b8,
		"a8": instance.a8,
		"h": instance.h,
		"s": instance.s,
		"v": instance.v,
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["r"] is float, "r is not a float")
	assert(serialized["g"] is float, "b is not a float")
	assert(serialized["b"] is float, "b is not a float")
	assert(serialized["a"] is float, "a is not a float")
	assert(serialized["r8"] is float, "r8 is not a float")
	assert(serialized["g8"] is float, "g8 is not a float")
	assert(serialized["b8"] is float, "b8 is not a float")
	assert(serialized["a8"] is float, "a8 is not a float")
	assert(serialized["h"] is float, "h is not a float")
	assert(serialized["s"] is float, "s is not a float")
	assert(serialized["v"] is float, "v is not a float")
	var color: Color = Color()
	color.r = serialized["r"]
	color.g = serialized["g"]
	color.b = serialized["b"]
	color.a = serialized["a"]
	color.r8 = int(serialized["r8"])
	color.g8 = int(serialized["g8"])
	color.b8 = int(serialized["b8"])
	color.a8 = int(serialized["a8"])
	color.h = serialized["h"]
	color.s = serialized["s"]
	color.v = serialized["v"]
	return color
