extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_BASIS


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Basis, "instance not of type Basis")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	return {
		"x": impl._vector3._serialize(instance.x, impl),
		"y": impl._vector3._serialize(instance.y, impl),
		"z": impl._vector3._serialize(instance.z, impl),
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["x"] is Dictionary, "x is not a Dictionary")
	assert(serialized["y"] is Dictionary, "y is not a Dictionary")
	assert(serialized["z"] is Dictionary, "z is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	
	return Basis(
		impl._vector3._deserialize(serialized["x"], impl), 
		impl._vector3._deserialize(serialized["y"], impl), 
		impl._vector3._deserialize(serialized["z"], impl)
	)
