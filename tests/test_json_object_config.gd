extends GutTest


func test_extended_config_returns_all_properties() -> void:
	# Set up parent config
	var parent_config: JSONObjectConfig = JSONObjectConfig.new()
	var parent_property: JSONProperty = JSONProperty.new()
	parent_property.json_key = "parent_config"
	parent_property.property_name = "parent_property"
	parent_config.properties.append(parent_property)
	
	# Set up extended config
	var child_config: JSONObjectConfig = JSONObjectConfig.new()
	var child_property: JSONProperty = JSONProperty.new()
	child_property.json_key = "child_config"
	child_property.property_name = "child_property"
	child_config.properties.append(child_property)
	
	child_config.extend_other_config = parent_config
	
	var properties: Array[JSONProperty] = child_config.get_properties_extended()
	assert_eq(properties.size(), 2, ("child_config.get_properties_extended() returned an array " + \
	"of size (%s) != 2, it should only be of size 2.") % properties.size())


func test_properties_override_extended_config() -> void:
	# Set up parent config
	var parent_config: JSONObjectConfig = JSONObjectConfig.new()
	var parent_property: JSONProperty = JSONProperty.new()
	parent_property.json_key = "parent_config"
	parent_property.property_name = "parent_property"
	parent_config.properties.append(parent_property)
	
	# Set up extended config
	var child_config: JSONObjectConfig = JSONObjectConfig.new()
	var child_property: JSONProperty = JSONProperty.new()
	child_property.json_key = "child_config"
	child_property.property_name = "parent_property"
	child_config.properties.append(child_property)
	
	child_config.extend_other_config = parent_config
	
	var properties: Array[JSONProperty] = child_config.get_properties_extended()
	assert_eq(properties.size(), 1, ("child_config.get_properties_extended() returned an array " + \
	"of size (%s) != 1, it should only be of size 1.") % properties.size())
	assert_eq(properties[0], child_property, ("child_property not returned by " + \
	"child_config.get_properties_extended(), instead it returned (%s)") % properties[0])
