## Dictionary serializer for 4.3 or earlier (no typed dictionary support)
extends JSONSerializer

const INDEX_PREFIX: String = ":"

func _index_key(index: int, key: String) -> String:
	return str(index) + INDEX_PREFIX + key


func _unindex_key(key: String) -> String:
	return key.split(":", true, 1)[1]


func _get_id() -> Variant:
	return TYPE_DICTIONARY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Dictionary, "instance not of type Dictionary")
	
	var dict_instance: Dictionary = instance as Dictionary
	
	var serialized: Dictionary = {}
	
	var index: int = 0
	for key: Variant in dict_instance:
		# NOTE: JSON keys need to be strings, so we use stringify here instead
		var serialized_key: String = impl.stringify(key)
		assert(!serialized_key.is_empty(), "serialized key (%s) empty for key (%s) of dictionary (%s)" \
		% [serialized_key, key, dict_instance])
		var serialized_value: Variant = impl.serialize(dict_instance[key])
		
		var indexed_key: String = _index_key(index, serialized_key)
		serialized[indexed_key] = serialized_value
		index += 1
	
	var result: Dictionary = {
		"k": {}, # We keep these here for compatibility with 4.4's serializer
		"v": {},
		"d": serialized,
	}
	
	return result



func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Dictionary, "serialized (%s) not of type Dictionary" % serialized)
	assert(serialized.has("d"), "serialized (%s) missing key 'd'" % serialized)
	
	var dict: Dictionary = {}
	_deserialize_into(serialized, dict, impl)
	
	return dict


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(instance is Dictionary, "instance not of type Dictionary")
	assert(serialized is Dictionary, "serialized not of type Dictionary")
	assert(serialized.has("d"), "serialized (%s) missing key 'd'" % serialized)
	assert(serialized.d is Dictionary, "serialized (%s) key (%s) not of type Dictionary" \
	% [serialized, serialized.d])
	
	for stringified_key: Variant in serialized.d:
		# JSON keys must be strings so we use parse instead of deserialize
		assert(stringified_key is String, ("key (%s) not of type String " + \
		"for serialized Dictionary (%s)") % [stringified_key, serialized.d])
		var unindexed_key: String = _unindex_key(stringified_key)
		var key: Variant = impl.parse(unindexed_key)
		var value: Variant = impl.deserialize(serialized.d[stringified_key])
		
		instance[key] = value
