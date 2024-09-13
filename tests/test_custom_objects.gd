extends GutTest

var object: JSONTestObjectExtended
var properties_to_test: Array[Array] = []
var deserialized: Object 

func before_all() -> void:
	JSONSerialization.object_config_registry = JSONObjectConfigRegistry.new()
	
	# Create JSONObjectConfig
	var config: JSONObjectConfig = JSONObjectConfig.new()
	config.id = &"JSONTestObject"
	
	# Load script & set it
	var gd_script: GDScript = preload("./util/json_test_object.gd") as GDScript
	config.set_for_class_by_script = gd_script
	
	# Create & set instantiator 
	config.instantiator = JSONScriptInstantiator.new()
	config.instantiator.gd_script = gd_script
	
	# Add JSONTestObject properties to config
	var parent_properties: PackedStringArray = PackedStringArray()
	for property: Dictionary in gd_script.get_script_property_list():
		if !property.name.begins_with(JSONTestObject.PROPERTY_PREFIX):
			continue
		parent_properties.append(property.name)
		var json_property: JSONProperty = JSONProperty.new()
		json_property.json_key = "key_" + property.name
		json_property.property_name = property.name
		config.properties.append(json_property)
	
	# Add config to global instance
	JSONSerialization.object_config_registry.add_config(config)
	
	# Create extended config
	var extended_config: JSONObjectConfig = JSONObjectConfig.new()
	extended_config.id = &"JSONTestObjectExtended"
	
	# Set original config to extend this one
	config.extend_other_config = extended_config
	
	# Load script & set it
	var extended_gd_script: GDScript = preload("./util/json_test_object_extended.gd") as GDScript
	extended_config.set_for_class_by_script = extended_gd_script
	
	# Add JSONTestObjectProperties to extended config
	for property: Dictionary in extended_gd_script.get_script_property_list():
		# Skip properties who aren't parents
		if !property.name.begins_with(JSONTestObject.PROPERTY_PREFIX) || parent_properties.has(property.name):
			continue
		var json_property: JSONProperty = JSONProperty.new()
		json_property.json_key = "key_" + property.name
		json_property.property_name = property.name
		extended_config.properties.append(json_property)
	
	# Create & set extended instantiator
	extended_config.instantiator = JSONScriptInstantiator.new()
	extended_config.instantiator.gd_script = extended_gd_script
	
	# Add extended to global instance
	JSONSerialization.object_config_registry.add_config(extended_config)
	
	# Create & set object
	object = JSONTestObjectExtended.new()
	
	# Register properties to test in param array
	for property: JSONProperty in JSONSerialization.object_config_registry.get_config_by_id(&"JSONTestObjectExtended")\
	.get_properties_extended():
		properties_to_test.append([property])


func after_all() -> void:
	# Reset config registry
	JSONSerialization.object_config_registry = JSONObjectConfigRegistry.new()
	# Clear objects
	object = null
	deserialized = null
	# Clear param array
	properties_to_test.clear()


func test_assert_registry_not_null() -> void:
	assert_not_null(JSONSerialization.object_config_registry, 
	"JSONSerialization.object_config_registry is null")


func test_assert_config_exists() -> void:
	assert_not_null(JSONSerialization.object_config_registry.get_config_by_id(&"JSONTestObject"),
	"Config ID 'JSONTestObject' does not exist in JSONSerialization.object_config_registry")


func test_assert_extended_config_exists() -> void:
	assert_not_null(JSONSerialization.object_config_registry.get_config_by_id(&"JSONTestObjectExtended"),
	"Config ID 'JSONTestObjectExtended' does not exist in JSONSerialization.object_config_registry")


func test_assert_extended_config_has_parent_properties() -> void:
	# Get config
	var config: JSONObjectConfig = JSONSerialization.object_config_registry.get_config_by_id(&"JSONTestObjectExtended")
	# Create array of property names to test for
	var property_names: PackedStringArray = PackedStringArray()
	for json_property: JSONProperty in config.get_properties_extended():
		property_names.append(json_property.property_name)
	
	for property: Dictionary in load("res://tests/util/json_test_object.gd").get_script_property_list():
		if !property.name.begins_with(JSONTestObject.PROPERTY_PREFIX):
			continue
		assert_has(property_names, property.name, ("JSONTestObject (parent) property (%s) missing from congig %s" + \
		".get_properties_extended()") % [config, property.name])


func test_assert_is_serializable() -> void:
	assert_true(JSONSerialization.is_serializiable(object), "JSONTestObject is not serializable")


func test_deserialized_is_correct_object() -> void:
	var serialized: String = JSONSerialization.stringify(object)
	deserialized = JSONSerialization.parse(serialized)
	assert_typeof(deserialized, TYPE_OBJECT, "deserialized type (%s) not of TYPE_OBJECT" \
	% typeof(deserialized))
	assert_is(deserialized, JSONTestObjectExtended, "deserialized not of type JSONTestObjectExtended")


func test_assert_property_deserialized_equals_original(params = use_parameters(properties_to_test)) -> void:
	var json_property: JSONProperty = params[0] as JSONProperty
	assert_not_null(json_property, "properties_to_test has null value (this is an error w/ this test)")
	
	assert_true(json_property.property_name in deserialized, ("deserialized does not contain expected " + \
	"property '%s'") % json_property.property_name)
	
	var original_value: Variant = object.get(json_property.property_name)
	var deserialized_value: Variant = deserialized.get(json_property.property_name)
	if original_value is Object:
		pass
	else:
		assert_eq()
