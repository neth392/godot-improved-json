extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_PACKED_COLOR_ARRAY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is PackedColorArray, "instance not of type PackedColorArray")
	assert(impl != null, "impl is null")
	assert(impl._color != null, "impl._color is null")
	var serialized: Array[Dictionary] = []
	var array: PackedColorArray = instance as PackedColorArray
	for color: Color in array:
		serialized.append(impl._color._serialize(color, impl))
	return serialized


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Array, "serialized not of type Array")
	assert(impl != null, "impl is null")
	assert(impl._color != null, "impl._color is null")
	
	var array: PackedColorArray = PackedColorArray()
	for serialized_color in serialized:
		array.append(impl._color._deserialize(serialized_color, impl))
	
	return array
