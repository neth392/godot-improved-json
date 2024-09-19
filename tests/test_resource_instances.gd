extends GutTest

var impl: JSONSerializationImpl
var config: JSONObjectConfig
var resource_file_instance: JSONResourceFileInstance
var resource: Resource

func before_all() -> void:
	impl = JSONSerialization.new_impl()
	impl.object_config_registry = JSONObjectConfigRegistry.new()
	config = preload("./util/json_test_resource_config.tres")
	impl.object_config_registry.add_config(config)
	resource = preload("./util/json_test_resource.tres")


func after_all() -> void:
	impl.queue_free()
	impl = null
	config = null
	resource = null


func test_assert_config_registered() -> void:
	assert_true(impl.object_config_registry.has_config(config), "config not registered")


func test_assert_can_serialize_resource() -> void:
	assert_true(impl.is_serializiable(resource), "impl.is_serializiable(resource) returned false")


func test_assert_resource_file_instance_in_config_id_dict() -> void:
	assert_has(config._file_instance_by_id, "json_test_resource.tres", \
	"json_test_resource.tres not present in config._file_instance_by_id")


func test_assert_resource_file_instance_in_config_path_dict() -> void:
	assert_has(config._file_instances_by_path, "res://tests/util/json_test_resource.tres", \
	"res://tests/util/json_test_resource.tres not present in config._file_instances_by_path")


func test_assert_deserialize_equals_original_via_id() -> void:
	config.json_res_use_resource_path = false
	var serialized: String = impl.stringify(resource)
	var deserialized: Variant = impl.parse(serialized)
	
	assert_is(deserialized, JSONTestResource, "deserialized (%s) not of type JSONTestResource" \
	% deserialized)
	
	assert_eq(deserialized, resource, "deserialized != resource instance")


func test_assert_deserialize_equals_original_via_path() -> void:
	config.json_res_use_resource_path = true
	var serialized: String = impl.stringify(resource)
	var deserialized: Variant = impl.parse(serialized)
	
	assert_is(deserialized, JSONTestResource, "deserialized (%s) not of type JSONTestResource" \
	% deserialized)
	
	assert_eq(deserialized, resource, "deserialized != resource instance")
