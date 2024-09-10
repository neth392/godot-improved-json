extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_VECTOR3I


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Vector3i, "instance not of type Vector3i")
	return {
		"x": instance.x,
		"y": instance.y,
		"z": instance.z,
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	assert(serialized["z"] is float, "z is not a float")
	return Vector3i(int(serialized["x"]), int(serialized["y"]), int(serialized["z"]))
