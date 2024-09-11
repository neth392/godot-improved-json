extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_PACKED_VECTOR3_ARRAY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is PackedVector3Array, "instance not of type PackedVector3Array")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	var serialized: Array[Dictionary] = []
	var array: PackedVector3Array = instance as PackedVector3Array
	for vector3: Vector3 in array:
		serialized.append(impl._vector3._serialize(vector3, impl))
	return serialized


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(impl != null, "impl is null")
	assert(impl._vector3 != null, "impl._vector3 is null")
	
	var array: PackedVector3Array = PackedVector3Array()
	for serialized_vector3 in serialized:
		array.append(impl._vector3._deserialize(serialized_vector3, impl))
	
	return array
