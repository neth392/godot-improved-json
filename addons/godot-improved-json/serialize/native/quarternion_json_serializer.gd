extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_QUATERNION


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Quaternion, "instance not of type Quaternion")
	return {
		"x": instance.x,
		"y": instance.y,
		"z": instance.z,
		"w": instance.w
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is float, "x is not a float")
	assert(serialized["y"] is float, "y is not a float")
	assert(serialized["z"] is float, "z is not a float")
	assert(serialized["w"] is float, "w is not a float")
	return Quaternion(
		serialized["x"],
		serialized["y"],
		serialized["z"],
		serialized["w"]
	)
