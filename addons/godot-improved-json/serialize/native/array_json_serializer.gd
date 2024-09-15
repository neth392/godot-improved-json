extends JSONSerializer


func _get_id() -> Variant:
	return TYPE_ARRAY


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Array, "instance not of type Array")
	
	var serialized: Array = []
	for element: Variant in instance:
		var serialized_element: Variant = impl.serialize(element)
		serialized.append(serialized_element)
	
	var array: Array = instance as Array
	
	# Return regular array for non-typed arrays
	if !array.is_typed():
		return serialized
	
	# Resolve typed dictionary
	var typed_dict: Dictionary = GodotJSONUtil.create_type_dict(impl, array.get_typed_builtin(), 
	array.get_typed_class_name(), array.get_typed_script())
	
	typed_dict["a"] = serialized
	
	return typed_dict


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(serialized is Array || (serialized is Dictionary && serialized.has("a")), \
	"serialized not of type Array, and a Dictionary with key 'a'")
	
	# Non typed array, can just return this
	if serialized is Array:
		var array: Array = []
		_deserialize_into(serialized, array, impl)
		return array
	
	# Typed array, need to construct a proper instance
	var array: Variant
	
	var dict: Dictionary = serialized as Dictionary
	
	if dict.has("t"): # Non-object typed array
		array = Array([], int(dict.t), "", null)
	elif dict.has("c"): # Built-in/native object typed array
		array = Array([], TYPE_OBJECT, StringName(dict.c), null)
	elif dict.has("i"): # Custom object typed array
		var config_id: StringName = StringName(dict.i)
		var config: JSONObjectConfig = impl.object_config_registry.get_config_by_id(config_id)
		assert(config != null, "no JSONObjectConfig found with id (%s) when deserializing array (%s)" \
		% [config_id, serialized])
		var script: Script = config.get_class_script()
		assert(script != null, "no script found for config (%s) when deserializing array (%s)" \
		% [config, serialized])
		array = Array([], TYPE_OBJECT, script.get_instance_base_type(), script)
	else: # Unrecognizable
		assert(false, ("Serialized array (%s) missing 't','c', & 'i' keys, must have one to " + \
		"properly construct an array of the correct type") % serialized)
	
	_deserialize_into(serialized, array, impl)
	return array


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(instance is Array, "instance not of type Array")
	assert(serialized is Array || (serialized is Dictionary && serialized.has("a")), \
	"serialized not of type Array, and a Dictionary with key 'a'")
	
	var elements: Array = serialized if serialized is Array else serialized.a
	
	for serialized_element: Variant in elements:
		var deserialized: Variant = impl.deserialize(serialized_element)
		instance.append(deserialized)
