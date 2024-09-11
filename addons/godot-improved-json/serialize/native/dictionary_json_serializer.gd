extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_DICTIONARY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Dictionary, "instance not of type Dictionary")
	
	if instance.is_empty():
		return {}
	
	var serialized: Dictionary = {}
	
	for key: Variant in instance:
		# NOTE: JSON keys need to be strins, so we use stringify here instead
		var serialized_key: String = impl.stringify(key)
		var serialized_value: Variant = impl.serialize(instance[key])
		
		serialized[serialized_key] = serialized_value
	
	return serialized


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	var dictionary: Variant = {}
	# NOTE: Add support for typed dictionaries eventually.
	_deserialize_into(serialized, dictionary, impl)
	return dictionary


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(instance is Dictionary, "instance not of type Dictionary")
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	
	for stringified_key: Variant in serialized:
		
		assert(stringified_key is String, ("key (%s) not of type String " + \
		"for serialized Dictionary (%s)") % [stringified_key, serialized])
		var key: Variant = impl.parse(stringified_key)
		var value: Variant = impl.deserialize(serialized[stringified_key])
		
		instance[key] = value
