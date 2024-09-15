# Tests all native types except Object, Dictionary, & Array
extends GutTest

var type_params: Array[Array] = []

func before_all():
	var object: Object = JSONTestUtil.load_test_object_script().new()
	for property: Dictionary in object.get_script().get_script_property_list():
		if !property.name.begins_with(JSONTestUtil.PROPERTY_PREFIX) || property.type == TYPE_OBJECT:
			continue
		type_params.append([property.name, object.get(property.name)])


func test_assert_property_not_null(params: Array = use_parameters(type_params)) -> void:
	assert_not_null(params[1], "test value null for property (%s)" % params[0])


func test_assert_deserialized_equals_original(params: Array = use_parameters(type_params)) -> void:
	var property_name: String = params[0]
	var value: Variant = params[1]
	
	var serialized: Variant = JSONSerialization.stringify(value)
	assert_not_null(serialized, ("JSONSerialization.stringify result is null for value (%s) of " + \
	"property (%s) w/ type (%s)") % [value, property_name, JSONTestUtil.get_type_of(value)])
	
	var deserialized: Variant = JSONSerialization.parse(serialized)
	assert_not_null(serialized, ("JSONSerialization.parse result is null for serialized value (%s) " + \
	"of property (%s) w/ type (%s)") % [serialized, property_name, JSONTestUtil.get_type_of(value)])
	
	var compare_result: Variant = compare_deep(value, deserialized)
	assert_true(compare_result.are_equal, ("deserialized value (%s) not equal to original (%s) of " + \
	"property (%s) w/ type (%s).\nCompareResult.summary=%s") % [deserialized, value, property_name, 
	JSONTestUtil.get_type_of(value), compare_result.summary])
