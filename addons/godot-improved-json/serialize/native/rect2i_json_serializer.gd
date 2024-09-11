extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_RECT2I


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Rect2i, "instance not of type Rect2i")
	assert(impl != null, "impl is null")
	assert(impl._vector2i != null, "impl._vector2i is null")
	return {
		"p": impl._vector2i._serialize(instance.position, impl),
		"e": impl._vector2i._serialize(instance.end, impl),
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized["p"] is Dictionary, "p is not a Dictionary")
	assert(serialized["e"] is Dictionary, "e is not a Dictionary")
	assert(impl != null, "impl is null")
	assert(impl._vector2i != null, "impl._vector2i is null")
	
	var rect2i: Rect2i = Rect2i()
	rect2i.position = impl._vector2i._deserialize(serialized["p"], impl)
	rect2i.end = impl._vector2i._deserialize(serialized["e"], impl)
	return rect2i
