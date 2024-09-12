extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_VECTOR4I


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Vector4i, "instance not of type Vector4i")
	return {
		"w": instance.w,
		"x": instance.x,
		"y": instance.y,
		"z": instance.z,
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["w"] is float, "w is not a float")
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	assert(serialized["z"] is float, "z is not a float")
	return Vector4i(int(serialized["x"]), int(serialized["y"]), int(serialized["z"]), int(serialized["w"]))
