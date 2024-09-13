extends GutTest

var impl: JSONSerializationImpl
var object: JSONTestObjectExtended
var properties_to_test: Array[Array] = []
var properties_to_test_names: PackedStringArray = PackedStringArray()
var deserialized: Object 

func before_all() -> void:
	# Create a new impl to use
	impl = JSONSerialization.new_impl()
	# Change these default values to preserve ordering
	impl.sort_keys = false
	impl.full_precision = true 
	
	# Give it a new registry for these tests
	impl.object_config_registry = JSONObjectConfigRegistry.new()
	
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
		properties_to_test_names.append(json_property.property_name)
	
	# Add config to global instance
	impl.object_config_registry.add_config(config)
	
	# Create extended config
	var extended_config: JSONObjectConfig = JSONObjectConfig.new()
	extended_config.id = &"JSONTestObjectExtended"
	
	# Set original config to extend this one
	extended_config.extend_other_config = config
	
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
		properties_to_test_names.append(json_property.property_name)
	
	# Create & set extended instantiator
	extended_config.instantiator = JSONScriptInstantiator.new()
	extended_config.instantiator.gd_script = extended_gd_script
	
	# Add extended to global instance
	impl.object_config_registry.add_config(extended_config)
	
	# Create & set object
	object = JSONTestObjectExtended.new()
	
	# Register properties to test in param array
	for property: JSONProperty in impl.object_config_registry.get_config_by_id(&"JSONTestObjectExtended")\
	.get_properties_extended():
		properties_to_test.append([property])


func after_all() -> void:
	# Get rid of impl
	impl.queue_free()
	impl = null
	# Clear objects
	object = null
	deserialized = null
	# Clear param array
	properties_to_test.clear()


func test_assert_impl_not_null() -> void:
	assert_not_null(impl, "impl is null")


func test_assert_registry_not_null() -> void:
	assert_not_null(impl.object_config_registry, "impl.object_config_registry is null")


func test_assert_config_exists() -> void:
	assert_not_null(impl.object_config_registry.get_config_by_id(&"JSONTestObject"),
	"Config ID 'JSONTestObject' does not exist in impl.object_config_registry")


func test_assert_extended_config_exists() -> void:
	assert_not_null(impl.object_config_registry.get_config_by_id(&"JSONTestObjectExtended"),
	"Config ID 'JSONTestObjectExtended' does not exist in impl.object_config_registry")


func test_assert_extended_config_has_parent_properties() -> void:
	# Get config
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_id(&"JSONTestObjectExtended")
	# Create array of property names to test for
	var property_names: PackedStringArray = PackedStringArray()
	for json_property: JSONProperty in config.get_properties_extended():
		property_names.append(json_property.property_name)
	
	for property: Dictionary in load("res://tests/util/json_test_object.gd").get_script_property_list():
		if !property.name.begins_with(JSONTestObject.PROPERTY_PREFIX):
			continue
		assert_has(property_names, property.name, ("JSONTestObject (parent) property (%s)" + \
		" missing from config %s.get_properties_extended()") % [property.name, config])


func test_assert_is_serializable() -> void:
	assert_true(impl.is_serializiable(object), "JSONTestObject is not serializable")


func test_deserialized_is_correct_object() -> void:
	var serialized: String = impl.stringify(object)
	deserialized = impl.parse(serialized)
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
	var result: String = _deep_compare(original_value, deserialized_value)
	assert_true(result.is_empty(), ("property (%s): deserialized value " + \
	"is (%s) not equal to the original value (%s)\ncause=%s") \
	% [json_property.property_name, deserialized_value, original_value, result])

# Below is custom comparator logic to help isolate which property is not correct
# and why. It searches deep into objects (& arrays/dictionarys who have objects)
# and returns the root reason that caused the variants to not be equal

func _deep_compare(original: Variant, deserialized: Variant) -> String:
	if typeof(original) != typeof(deserialized):
			return "type of original (%s) != type of deserialized (%s)" \
			% [JSONTestUtil.get_type_of(original), JSONTestUtil.get_type_of(deserialized)]
	elif original is Object:
		return _deep_compare_object(original, deserialized)
	elif original is Array:
		return _deep_compare_array(original, deserialized)
	elif original is Dictionary:
		return _deep_compare_dictionary(original, deserialized)
	elif original != deserialized:
		return "natives not equal (original == deserialized returned false)"
	else:
		return ""


func _deep_compare_array(original: Array, deserialized: Variant) -> String:
	if deserialized is not Array:
		return "deserialized not of type Array"
	if original.size() != deserialized.size():
		return "array size mismatch: original=%s, deserialized=%s" % [original.size(), deserialized.size()]
	
	for index: int in original.size():
		var original_element: Variant = original[index]
		var deserialized_element: Variant = deserialized[index]
		var result: String = _deep_compare(original_element, deserialized_element)
		if !result.is_empty():
			return ("elements != @ index (%s) for original element (%s) & deserialized " + \
			"element (%s)\ncause=%s") % [index, original_element, deserialized_element, result]
	
	return ""


func _deep_compare_dictionary(original: Dictionary, deserialized: Variant) -> String:
	if deserialized is not Dictionary:
		return "deserialized not of type Dictionary"
	if original.size() != deserialized.size():
		return "dictionary size mismatch: original=%s, deserialized=%s" \
		% [original.size(), deserialized.size()]
	
	var original_keys: Array = original.keys()
	var deserialized_keys: Array = deserialized.keys()
	for index: int in original_keys.size():
		var original_key: Variant = original_keys[index]
		var deserialized_key: Variant = deserialized_keys[index]
		var key_result: String = _deep_compare(original_key, deserialized_key)
		if !key_result.is_empty():
			return ("keys != @ index (%s) for original key (%s) & deserialized " + \
			"key (%s)\ncause=%s") % [index, original_key, deserialized_key, key_result]
		
		var original_value: Variant = original[original_key]
		var deserialized_value: Variant = deserialized[deserialized_key]
		var value_result: String = _deep_compare(original_value, deserialized_value)
		if !value_result.is_empty():
			return ("values != @ index (%s) for original value (%s) & deserialized " + \
			"value (%s) of key (%s)\ncause=%s") \
			% [index, original_key, deserialized_key, original_key, key_result]
	
	return ""

# Only supports JSONTestObjectExtended
func _deep_compare_object(original: Object, deserialized: Variant) -> String:
	if deserialized is not Object:
		return "deserialized not of type Object"
	
	var original_class: String = GodotJSONUtil.get_class_name(original)
	var deserialized_class: String = GodotJSONUtil.get_class_name(deserialized)
	if original_class != deserialized_class:
		return "deserialized class (%s) != original class (%s)" % [original_class, deserialized_class]
	
	if original.get_script() != deserialized.get_script():
		return "deserialized script (%s) != original script (%s)" \
		% [original.get_script(), deserialized.get_script()]
	
	for property: Dictionary in original.get_property_list():
		if !properties_to_test_names.has(property.name):
			continue
		if property.name not in deserialized:
			return "property (%s) not found in deserialized (%s) but present in original (%s)" \
			% [property.name, deserialized, original]
		var original_value: Variant = original.get(property.name)
		var deserialized_value: Variant = deserialized.get(property.name)
		var result: String = _deep_compare(original_value, deserialized_value)
		if !result.is_empty():
			return ("property values != for property (%s) original value=(%s), " + \
			"deserialized value= (%s)\ncause=%s") \
			% [property.name, original_value, deserialized_value, result]
	
	return ""
