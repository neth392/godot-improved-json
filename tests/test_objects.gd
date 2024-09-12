extends GutTest

var object: JSONTestObject
var properties_to_test: Array[Array] = []
var deserialized: Object 

func before_all() -> void:
	object = JSONTestObject.new()
	object.type_object = JSONTestObject.new()
	
	# Register properties to test
	for property: JSONProperty in JSONSerialization.object_config_registry.get_config_by_id(&"JSONTestObject")\
	.properties:
		properties_to_test.append([property])


func after_all() -> void:
	object.type_object.free()
	object.free()
	object = null
	deserialized.free()
	deserialized = null
	properties_to_test.clear()


func test_assert_registry_not_null() -> void:
	assert_not_null(JSONSerialization.object_config_registry, 
	"JSONSerialization.object_config_registry is null")


func test_assert_config_exists() -> void:
	assert_not_null(JSONSerialization.object_config_registry.get_config_by_id(&"JSONTestObject"),
	"Config ID 'JSONTestObject' does not exist in JSONSerialization.object_config_registry")


func test_assert_is_serializable() -> void:
	assert_true(JSONSerialization.is_serializiable(object), "JSONTestObject is not serializable")


func test_deserialized_is_correct_object() -> void:
	var serialized: String = JSONSerialization.stringify(object)
	var deserialized: Variant = JSONSerialization.parse(serialized)
	assert_typeof(deserialized, TYPE_OBJECT, "deserialized type (%s) not of TYPE_OBJECT" \
	% typeof(deserialized))
	assert_is(deserialized, JSONTestObject, "deserialized not of type JSONTestObject")


func test_assert_property_deserialized_equals_original(params = use_parameters(properties_to_test)) -> void:
	var json_property: JSONProperty = params[0] as JSONProperty
	assert_not_null(json_property, "properties_to_test has null value (this is an error w/ this test)")
	
	deserialized.get(json_property.property_name)




func _deep_compare(original: Object, deserialized: Object) -> void:
	for property: Dictionary in original.get_property_list():
		if !property.name.begins_with("type_"):
			continue
		
		assert_true(property.name in deserialized, "property (%s) not found in deserialized (%s)" \
		% [property.name, deserialized])
		var original_value: Variant = original.get(property.name)
		var deserialized_value: Variant = deserialized.get(property.name)
		
		if original_value is Object:
			assert_not_null(deserialized_value, ("property (%s) deserialized is null but original " + \
			"value is (%s)") % [property.name, original_value])
			if deserialized_value == null: # Skip rest of tests if null
				continue
			var original_class: StringName = GodotJSONUtil.get_class_name(original_value)
			var deserialized_class: StringName = GodotJSONUtil.get_class_name(deserialized_value)
			
			# Assert deserialized class matches original
			assert_eq(deserialized_class, original_class, ("property (%s) in deserialized not of " + \
			"correct class, expected (%s) but is (%s)") % [property.name, original_class, deserialized_class])
			
			# Assert script matches
			assert_eq(original_value.get_script(), deserialized_value.get_script(), ("property (%s) " + \
			"in deserialized does not have same script as original, expected (%s) but has (%s)") \
			% [property.name, original_value.get_script(), deserialized_value.get_script()])
			
			# Deep compare
			_deep_compare(original_value, deserialized_value)
			continue
		
		assert_eq(deserialized_value, original_value, ("property (%s) of deserialized (%s) not equal " + \
		"to expected original value (%s)") % [property.name, deserialized_value, original_value])
