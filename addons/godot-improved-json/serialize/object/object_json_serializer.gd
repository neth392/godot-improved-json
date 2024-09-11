@tool
extends JSONSerializer

func _get_id() -> Variant:
	return TYPE_OBJECT


func _serialize(instance: Variant, impl: JSONSerializationImpl) -> Variant:
	assert(instance is Object, "instance not of type Object")
	
	var object: Object = instance as Object
	
	# Determine the class
	var object_class: StringName = GodotJSONUtil.get_class_name(object)
	assert(!object_class.is_empty(), "object (%s) does not have a class defined" % object_class)
	
	# Get the config by class
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_class(object_class)
	assert(config != null, "no JSONObjectConfig found for object_class %s" % object_class)
	
	var serialized: Dictionary = {}
	
	# Iterate the properies
	for property: JSONProperty in config.get_properties_extended():
		# Skip disabled properties
		if !property.enabled:
			continue
		
		# Ensure no duplicates
		assert(!serialized.has(property.json_key), "duplicate json_keys (%s) for object (%s)" \
		% [property.json_key, object])
		
		# Check if property exists in the object
		if property.property_name not in object:
			match property.if_missing_in_object_serialize:
				JSONProperty.IfMissing.WARN_DEBUG:
					push_warning("property (%s) missing in object (%s)" % [property, object])
				JSONProperty.IfMissing.ERROR_DEBUG:
					assert(false, "property (%s) missing in object (%s)" % [property, object])
			continue
		
		var value: Variant = object.get(property.property_name)
		serialized[property.json_key] = impl.serialize(value)
	
	# Wrap value with an extra dictionary to store which deserializer to use
	return {
		"i": config.id,
		"v": serialized,
	}


func _deserialize(serialized: Variant, impl: JSONSerializationImpl) -> Variant:
	var config: JSONObjectConfig = _get_config(serialized, impl)
	
	assert(config.instantiator != null, ("config (%s)'s instantiator is null, use " + \
	"_deserialize_into() with an existing instance instead") % config)
	assert(config.instantiator._can_instantiate(), ("cant instantiate config %s, use " + \
	"_deserialize_into() with an existing instance instead") % config)
	
	# Create instance
	var instance: Object = config.instantiator._instantiate()
	assert(instance != null, "config (%s)'s instantiator._instantiate() returned null" % config)
	
	_deserialize_into_w_config(serialized, instance, impl, config)
	
	return instance


func _deserialize_into(serialized: Variant, instance: Variant, impl: JSONSerializationImpl) -> void:
	assert(instance != null, "instance is null; can't deserialize into a null instance")
	assert(instance is Object, "instance not of type Object")
	
	# Determine config ID
	var config: JSONObjectConfig = _get_config(serialized, impl)
	_deserialize_into_w_config(serialized, instance, impl, config)


func _get_config(serialized: Dictionary, impl: JSONSerializationImpl) -> JSONObjectConfig:
	assert(serialized is Dictionary, "serialized not null or of type Dictionary")
	assert(serialized.has("i"), "serialized (%s) missing 'i' key" % serialized)
	# Determine config ID
	var config_id: StringName = StringName(serialized.i)
	assert(!config_id.is_empty(), "config_id empty for serialized (%s)" % serialized)
	
	# Determine config
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_id(config_id)
	assert(config != null, "no config with id (%s) found" % config_id)
	
	return config



func _deserialize_into_w_config(serialized: Dictionary, object: Object, impl: JSONSerializationImpl,
config: JSONObjectConfig) -> void:
	assert(serialized.has("v"), "serialized (%s) missing 'v' key" % serialized)
	
	var serialized_object: Dictionary = serialized.get("v") as Dictionary
	assert(serialized_object is Dictionary, "serialized[v] not of type Dictionary, serialized=%s" \
	% serialized)
	
	for property: JSONProperty in config.get_properties_extended():
		# Property not in object
		if property.property_name not in object:
			match property.if_missing_in_object_deserialize:
				JSONProperty.IfMissing.WARN_DEBUG:
					push_warning("property (%s) missing in object (%s)" % [property, object])
				JSONProperty.IfMissing.ERROR_DEBUG:
					assert(false, "property (%s) missing in object (%s)" % [property, object])
			continue
		
		# Property not in serialized
		if property.json_key not in serialized_object:
			match property.if_missing_in_json:
				JSONProperty.IfMissing.WARN_DEBUG:
					push_warning("property (%s) missing in serialized_object (%s)" \
					% [property, serialized_object])
				JSONProperty.IfMissing.ERROR_DEBUG:
					assert(false, "property (%s) missing in serialized_object (%s)" \
					% [property, serialized_object])
			continue
		
		var serialized_property: Variant = serialized_object.get(property.json_key)
		var current_property: Variant = object.get(property.property_name)
		
		# Deserialize into
		if current_property != null \
		and property.deserialize_into \
		and impl.can_deserialize_into_type(typeof(current_property)):
			
			impl.deserialize_into(serialized_property, current_property)
			
		else: # Deserialize
			var deserialized_property: Variant = impl.deserialize(serialized_property)
			object.set(property.property_name, deserialized_property)
