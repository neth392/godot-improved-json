# Tests all native types except Object, Dictionary, & Array
extends GutTest

var type_params: Array[Array] = []


func before_all():
	var object: JSONTestObject = JSONTestObject.new()
	for property: Dictionary in object.get_script().get_script_property_list():
		if !property.name.begins_with("type_"):
			continue
		type_params.append([property.name, object.get(property.name)])
	object.free()


func test_assert_property_not_null(params: Array = use_parameters(type_params)) -> void:
	assert_not_null(params[1], "test value null for property (%s)" % params[0])


func test_assert_deserialized_equals_original(params: Array = use_parameters(type_params)) -> void:
	var value: Variant = params[1]
	
	var serialized: Variant = JSONSerialization.stringify(value)
	assert_not_null(serialized, "JSONSerialization.stringify result is null for value (%s) for type (%s)" \
	% [value, JSONTestUtil.get_type_of(value)])
	
	var deserialized: Variant = JSONSerialization.parse(serialized)
	assert_not_null(serialized, "JSONSerialization.parse result is null for serialized value (%s) for type (%s)" \
	% [serialized, JSONTestUtil.get_type_of(value)])
	
	assert_eq(deserialized, value, "deserialized value (%s) not equal to original (%s) for type (%s)" \
	% [deserialized, value, JSONTestUtil.get_type_of(value)])
