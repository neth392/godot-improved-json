extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_DICTIONARY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Dictionary, "instance not of type Dictionary")
	
	if instance.is_empty():
		return {}
	
	var dict: Dictionary = instance as Dictionary
	
	var serialized: Dictionary = {}
	
	for key: Variant in instance:
		# NOTE: JSON keys need to be strins, so we use stringify here instead
		var serialized_key: String = impl.stringify(key)
		var serialized_value: Variant = impl.serialize(instance[key])
		
		serialized[serialized_key] = serialized_value
	
	var result: Dictionary = {
		"k": {},
		"v": {},
		"d": serialized,
	}
	
	# Set key type
	if dict.is_typed_key():
		result.k = GodotJSONUtil.create_type_dict(impl, dict.get_typed_key_builtin(), 
		dict.get_typed_key_class_name(), dict.get_typed_key_script())
	
	# Set value type
	if dict.is_typed_value():
		result.v = GodotJSONUtil.create_type_dict(impl, dict.get_typed_value_builtin(), 
		dict.get_typed_value_class_name(), dict.get_typed_value_script())
	
	return result



func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized (%s) not of type Dictionary" % serialized)
	assert(serialized.has("d"), "serialized (%s) missing key 'd'" % serialized)
	assert(serialized.has("k"), "serialized (%s) missing key 'k'" % serialized)
	assert(serialized.has("v"), "serialized (%s) missing key 'v'" % serialized)
	
	var dict: Dictionary
	
	# 
	if dict.k.is_empty() && dict.v.is_empty():
		dict = {}
	else:
		
	
	_deserialize_into(serialized, dictionary, impl)
	
	return dictionary


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(instance is Dictionary, "instance not of type Dictionary")
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized.has("d"), "serialized (%s) missing key 'd'" % serialized)
	
	var dict: Dictionary = serialized.d
	for stringified_key: Variant in dict:
		assert(stringified_key is String, ("key (%s) not of type String " + \
		"for serialized Dictionary (%s)") % [stringified_key, dict])
		var key: Variant = impl.parse(stringified_key)
		var value: Variant = impl.deserialize(dict[stringified_key])
		
		instance[key] = value