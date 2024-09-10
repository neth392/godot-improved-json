extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_PROJECTION


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Projection, "instance not of type Projection")
	assert(impl != null, "impl is null")
	assert(impl._vector4 != null, "impl._vector4 is null")
	return {
		"x": impl._vector4._serialize(instance.x, impl),
		"y": impl._vector4._serialize(instance.y, impl),
		"z": impl._vector4._serialize(instance.z, impl),
		"w": impl._vector4._serialize(instance.w, impl),
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is Dictionary, "x is not a Dictionary")
	assert(serialized["y"] is Dictionary, "y is not a Dictionary")
	assert(serialized["z"] is Dictionary, "z is not a Dictionary")
	assert(serialized["w"] is Dictionary, "w is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector4 != null, "impl._vector4 is null")
	
	return Projection(
		impl._vector4._deserialize(serialized["x"], impl),
		impl._vector4._deserialize(serialized["y"], impl),
		impl._vector4._deserialize(serialized["z"], impl),
		impl._vector4._deserialize(serialized["w"], impl),
	)
