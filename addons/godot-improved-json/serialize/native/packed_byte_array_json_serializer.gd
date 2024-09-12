extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_PACKED_BYTE_ARRAY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is PackedByteArray, "instance not of type PackedByteArray")
	var serialized: Array = []
	for byte in instance:
		serialized.append(byte)
	return serialized


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	
	var array: PackedByteArray = PackedByteArray()
	for serialized_byte in serialized:
		array.append(serialized_byte)
	
	return array
