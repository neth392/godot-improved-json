@tool
extends Serializer

func _get_id() -> Variant:
	return TYPE_OBJECT


func _serialize(instance: Variant, impl: SerializationImpl) -> Variant:
	assert(instance is Object, "instance not of type Object")
	
	var object: Object = instance as Object
	
	var to_return: Dictionary = {}
	
	# WeakRef support, mark as wekref & reassign object to the referred
	if object is WeakRef:
		to_return["w"] = 1
		object = object.get_ref()
		# Infinite WeakRefs (no idea why anyone would nest weakrefs but someone might...)
		while object is WeakRef:
			to_return["w"] += 1
			object = object.get_ref()
		
		# WeakRef with null value
		if object == null:
			to_return["wn"] = "t"
			return to_return
	
	# Determine the class
	var object_class: StringName = SerializationUtil.get_class_name(object)
	assert(!object_class.is_empty(), "object (%s) does not have a class defined" % object_class)
	
	# Get the config by class
	var config: SerializationObjectConfig = impl.object_config_registry.get_config_by_class(object_class)
	assert(config != null, "no SerializationObjectConfig found for object_class %s" % object_class)
	
	var serialized: Dictionary = {}
	to_return["i"] = config.id
	to_return["v"] = serialized
	
	if config.is_resource() && config.json_res_maintain_resource_instances:
		
		assert(object is Resource, ("object (%s) not of type Resource but its  " + \
		"SerializationObjectConfig(%s) has json_res_maintain_resource_instances as true") % [object, config.id])
		
		if !object.resource_path.is_empty():
			
			# Handle configs for resources with maintain instances
			if config.json_res_use_resource_path:
				
				to_return["r"] = object.resource_path
				if config.json_res_include_properties_in_file_instances:
					_serialize_set_properties(object, config, serialized, impl)
				return to_return
			
			# Handle configs for resources with individual instances
			var file_instance: ResourceFileInstance = config._file_instances_by_path.get(object.resource_path)\
			as ResourceFileInstance
			
			if file_instance != null:
				# ResourceFileInstance exists, serialize via that method
				to_return["r"] = file_instance.id
				if file_instance.include_properties:
					_serialize_set_properties(object, config, serialized, impl)
				return to_return
			
			# At this point no proper resource info could be determined, serialize it like a normal object
	
	_serialize_set_properties(object, config, serialized, impl)
	return to_return


func _serialize_set_properties(object: Object, config: SerializationObjectConfig, serialized: Dictionary,
impl: SerializationImpl) -> void:
	# Iterate the properies
	for property: SerializableProperty in config.get_properties_extended():
		# Ensure key not empty
		assert(!property.key.is_empty(), "SerializableProperty (%s) of config (%s) has empty key" \
		% [property, config])
		# Check for duplicate keys
		assert(!serialized.has(property.key), "duplicate keys (%s) for SerializationObjectConfig (%s)" \
		% [property.key, config])
		
		# Skip disabled properties
		if !property.enabled:
			continue
		
		# Check if property exists in the object
		if property.property_name not in object:
			
			match property.if_missing_in_object_serialize:
				SerializableProperty.IfMissing.WARN_DEBUG:
					push_warning("property (%s) missing in object (%s) of class (%s)" \
					% [property, object, SerializationUtil.get_class_name(object)])
				SerializableProperty.IfMissing.ERROR_DEBUG:
					assert(false, "property (%s) missing in object (%s) of class (%s)" \
					% [property, object, SerializationUtil.get_class_name(object)])
			continue
		
		var value: Variant = object.get(property.property_name)
		serialized[property.key] = impl.serialize(value)


func _deserialize(serialized: Variant, impl: SerializationImpl) -> Variant:
	# Is null WeakRef
	if serialized.has("wn"):
		var instance: WeakRef = weakref(null)
		for i: int in (int(serialized["w"]) - 1):
			if impl._test_mode_DO_NOT_TOUCH:
				instance.reference()
			instance = weakref(instance)
		return instance
	
	var config: SerializationObjectConfig = _get_config(serialized, impl)
	
	var instance: Object
	
	# Handle resource instances
	if config.is_resource() && config.json_res_maintain_resource_instances && serialized.has("r"):
		# Handle by path
		if config.json_res_use_resource_path:
			var path: String = serialized["r"] as String
			assert(ResourceLoader.exists(path), ("no resource exists at path (%s) when" + \
			"trying to deserialized object (%s)") % [path, serialized])
			instance = load(path)
			assert(instance != null, ("could not load resource at path (%s) when" + \
			"trying to deserialized object (%s)") % [path, serialized])
			if config.json_res_include_properties_in_file_instances:
				_deserialize_set_properties(serialized, instance, impl, config)
			return instance
		else:
			# Handle by file_instance
			var file_instance: ResourceFileInstance = config._file_instance_by_id.get(serialized["r"]) \
			as ResourceFileInstance
			if file_instance != null:
				assert(file_instance.resource != null, "%s's resource property is null" % file_instance)
				instance = file_instance.resource
				if file_instance.include_properties:
					_deserialize_set_properties(serialized, instance, impl, config)
				return instance
	
	assert(config.instantiator != null, ("config (%s)'s instantiator is null, use " + \
	"_deserialize_into() with an existing instance instead when deserializing (%s)") \
	% [config, serialized])
	assert(config.instantiator._can_instantiate(), ("cant instantiate config %s, use " + \
	"_deserialize_into() with an existing instance instead when deserializing (%s)") \
	% [config, serialized])
	
	# Create instance
	instance = config.instantiator._instantiate()
	assert(instance != null, "config (%s)'s instantiator._instantiate() returned null" % config)
	
	_deserialize_set_properties(serialized, instance, impl, config)
	
	# WeakRef support
	if serialized.has("w"):
		if impl._test_mode_DO_NOT_TOUCH && instance is RefCounted:
			instance.reference()
		instance = weakref(instance)
		for i: int in (int(serialized["w"]) - 1):
			if impl._test_mode_DO_NOT_TOUCH:
				instance.reference()
			instance = weakref(instance)
	
	return instance


func _deserialize_into(serialized: Variant, instance: Variant, impl: SerializationImpl) -> void:
	assert(instance != null, "instance is null; can't deserialize into a null instance")
	assert(instance is Object, "instance not of type Object")
	assert(!serialized.has("w") || !(instance is WeakRef), "serialized data & instance have a " + \
	"WeakRef type mismatch; serialized data does not contain 'w' key or instance is not of type WeakRef")
	assert(!serialized.has("wn"), "serialized of type WeakRef will null ref, can not deserialize into")
	
	# WeakRef support
	while instance is WeakRef:
		instance = instance.get_ref()
		assert(instance != null, "instance's WeakRef.get_ref() is null; can't deserialize into a null instance")
		assert(instance is Object, "instance's WeakRef.get_ref() not of type Object")
	
	# Determine config ID
	var config: SerializationObjectConfig = _get_config(serialized, impl)
	_deserialize_set_properties(serialized, instance, impl, config)


func _get_config(serialized: Dictionary, impl: SerializationImpl) -> SerializationObjectConfig:
	assert(serialized is Dictionary, "serialized not null or of type Dictionary")
	assert(serialized.has("i"), "serialized (%s) missing 'i' key" % serialized)
	# Determine config ID
	var config_id: StringName = StringName(serialized.i)
	assert(!config_id.is_empty(), "config_id empty for serialized (%s)" % serialized)
	
	# Determine config
	var config: SerializationObjectConfig = impl.object_config_registry.get_config_by_id(config_id)
	assert(config != null, "no config with id (%s) found" % config_id)
	
	return config



func _deserialize_set_properties(serialized: Dictionary, object: Object, impl: SerializationImpl,
config: SerializationObjectConfig) -> void:
	assert(serialized.has("v"), "serialized (%s) missing 'v' key" % serialized)
	
	var serialized_object: Dictionary = serialized.get("v") as Dictionary
	assert(serialized_object is Dictionary, "serialized[v] not of type Dictionary, serialized=%s" \
	% serialized)
	
	for property: SerializableProperty in config.get_properties_extended():
		# Property not in object
		if property.property_name not in object:
			match property.if_missing_in_object_deserialize:
				SerializableProperty.IfMissing.WARN_DEBUG:
					push_warning("property (%s) missing in object (%s)" % [property, object])
				SerializableProperty.IfMissing.ERROR_DEBUG:
					assert(false, "property (%s) missing in object (%s)" % [property, object])
			continue
		
		# Property not in serialized
		if property.key not in serialized_object:
			match property.if_missing_in_json:
				SerializableProperty.IfMissing.WARN_DEBUG:
					push_warning("property (%s) missing in serialized_object (%s)" \
					% [property, serialized_object])
				SerializableProperty.IfMissing.ERROR_DEBUG:
					assert(false, "property (%s) missing in serialized_object (%s)" \
					% [property, serialized_object])
			continue
		
		var serialized_property: Variant = serialized_object.get(property.key)
		var current_property: Variant = object.get(property.property_name)
		
		# Deserialize into
		if current_property != null \
		and property.deserialize_into \
		and impl.can_deserialize_into_type(typeof(current_property)):
			
			impl.deserialize_into(serialized_property, current_property)
			
		else: # Deserialize
			var deserialized_property: Variant = impl.deserialize(serialized_property)
			object.set(property.property_name, deserialized_property)
