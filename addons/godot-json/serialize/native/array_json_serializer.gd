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
	
	# Note on the below code:
	# For typed arrays we need to store information that tells us how to construct the same array.
	# Only information that is serialized are things NOT meant to change; built in class names
	# & JSONObjectConfig.id's. Custom class names & script paths can change & we don't want that breaking
	# the serialized data
	
	# Return the type & array for non-object types (dont require a class or script)
	if array.get_typed_builtin() != TYPE_OBJECT:
		return {
			"t": array.get_typed_builtin(), # The typed built in
			"a": serialized, # The array
		}
	
	# Make sure the class exists (no reason it shouldn't)
	assert(!array.get_typed_class_name().is_empty(), "array (%s)'s typed class name is empty" % str(array))
	
	# For built in objects, we can just return the class name. Those won't change, and if the do
	# then other parts of projects will break too (not our problem to worry about)
	# Can omit the type since if "c" is present, we know it's TYPE_OBJECT
	if array.get_typed_script() == null:
		return {
			"c": array.get_typed_class_name(),
			"a": serialized
		}
	
	# For custom classes, we'll resolve the JSONObjectConfig for that type. It HAS to exist
	# for elements to be serialized anyways, so if it doesn't an error will be thrown.
	# Need to include the base type class name too in order to please Array's constructor
	
	# First, get the custom class name from script
	assert(array.get_typed_script() is Script, "array (%s)'s type's script (%s) not of type Script" \
	% [array, array.get_typed_script()])
	
	var script: Script = array.get_typed_script() as Script
	assert(!script.get_global_name().is_empty(), ("array (%s)'s type's script (%s) does not have a " + \
	"class_name defined") % [array, script])
	
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_class(script.get_global_name())
	assert(config != null, "array (%s)'s type (%s) does not have a JSONObjectConfig associated with it" \
	% [array, script.get_global_name()])
	
	return {
		"i": config.id, # ID of the config, can resolve class name & base type from this
		"a": serialized, # The array
	}


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
		array = Array([], TYPE_OBJECT, dict.c, null)
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
		var deserialized: Variant = JSONSerialization.deserialize(serialized_element)
		instance.append(deserialized)
