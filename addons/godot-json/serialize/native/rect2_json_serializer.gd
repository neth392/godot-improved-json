extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_RECT2


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Rect2, "instance not of type Rect2")
	assert(impl != null, "impl is null")
	assert(impl._vector2 != null, "impl._vector2 is null")
	return {
		"p": impl._vector2._serialize(instance.position, impl),
		"e": impl._vector2._serialize(instance.end, impl),
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["p"] is Dictionary, "p is not a Dictionary")
	assert(serialized["e"] is Dictionary, "e is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector2 != null, "impl._vector2 is null")
	
	var rect2: Rect2 = Rect2()
	rect2.position = impl._vector2._deserialize(serialized["p"], impl)
	rect2.end = impl._vector2._deserialize(serialized["e"], impl)
	return rect2
