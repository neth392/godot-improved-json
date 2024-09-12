extends GutHookScript

func run():
	JSONSerialization.object_config_registry = preload("./test_json_object_config_registry.tres")
	
	# Create JSONObjectConfig
	var config: JSONObjectConfig = JSONObjectConfig.new()
	config.id = &"JSONTestObject"
	
	# Load script & set it
	var gd_script: GDScript = preload("./json_test_object.gd") as GDScript
	config.set_for_class_by_script = gd_script
	
	# Create & set instantiator 
	config.instantiator = JSONScriptInstantiator.new()
	config.instantiator.gd_script = gd_script
	
	# Add JSONTestObject properties to config
	for property: Dictionary in gd_script.get_script_property_list():
		if !property.name.begins_with("type_"):
			continue
		var json_property: JSONProperty = JSONProperty.new()
		json_property.json_key = "key_" + property.name
		json_property.property_name = property.name
		config.properties.append(json_property)
	
	# Add config to global instance
	JSONSerialization.object_config_registry.add_config(config)
