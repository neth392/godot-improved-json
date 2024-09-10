extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_VECTOR3


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Vector3, "instance not of type Vector3")
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
	return Vector3(serialized["x"], serialized["y"], serialized["z"])
