extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_PLANE


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Plane, "instance not of type Plane")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	return {
		"n": impl._vector3._serialize(instance.normal, impl),
		"d": instance.d,
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["n"] is Dictionary, "n is not a Dictionary")
	assert(serialized["d"] is float, "d is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	
	return Plane(
		impl._vector3._deserialize(serialized["n"], impl),
		serialized["d"]
	)
