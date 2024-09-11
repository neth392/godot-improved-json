extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_PACKED_VECTOR4_ARRAY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is PackedVector4Array, "instance not of type PackedVector4Array")
	assert(impl != null, "impl is null")
	assert(impl._vector4 != null, "impl._vector4 is null")
	
	var serialized: Array[Dictionary] = []
	var array: PackedVector4Array = instance as PackedVector4Array
	for vector4: Vector4 in array:
		serialized.append(impl._vector4._serialize(vector4, impl))
	return serialized


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(impl != null, "impl is null")
	assert(impl._vector4 != null, "impl._vector4 is null")
	
	var array: PackedVector4Array = PackedVector4Array()
	for serialized_vector4 in serialized:
		array.append(impl._vector4._deserialize(serialized_vector4, impl))
	
	return array
