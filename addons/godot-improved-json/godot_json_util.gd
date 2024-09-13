## Some utilities used across the project.
@tool
class_name GodotJSONUtil extends Object


## Returns the number of times the method with the name [param method_name]
## appears in the [param script]'s [method Script.get_script_method_list]. Useful
## for determining if a method is inherited or not.
static func get_method_count(script: Script, method_name: String):
	var count: int = 0
	for method: Dictionary in script.get_script_method_list():
		if method.name == method_name:
			count += 1
	return count


## Returns the [Script]'s resource_path from the custom class [param _class_name],
## or an empty string if no custom class with [param _class_name] exists.
static func get_script_path_from_class_name(_class_name: StringName) -> String:
	for global_class: Dictionary in ProjectSettings.get_global_class_list():
		if global_class.class == _class_name:
			return global_class.path
	return ""


## Resolves the class name from the [param object],returns an empty [StringName]
## if the [param object] does not have a valid class name.
static func get_class_name(object: Object) -> StringName:
	assert(object != null, "object is null")
	var script: Script = object.get_script() as Script
	if script != null && !script.get_global_name().is_empty():
		return script.get_global_name()
	if !object.get_class().is_empty():
		return object.get_class()
	return &""


## Helper function for use with serializing typed arrays & dictionaries (i.e. collections)
## Returns one of the following options:
## [br]{"t":[param type]} if any type besides TYPE_OBJECT
## [br]{"c":[param type_class] if [param type_script] is null (the type is then a built-in object]
## [br]{"i":[member JSONObjectConfig.id]} if there is a script attached & thus is a custom class.
static func create_type_dict(impl: JSONSerializationImpl, type: Variant.Type, 
type_class: StringName, type_script: Script) -> Dictionary:
	# Note on the below code:
	# For typed collections we need to store information that tells us how to construct the same collections.
	# Only information that is serialized are things NOT meant to change; built in class names
	# & JSONObjectConfig.id's. Custom class names & script paths can change & we don't want that breaking
	# the serialized data
	
	# Return the type  for non-object types (dont require a class or script)
	if type != TYPE_OBJECT:
		return {
			"t": type, # The typed built in
		}
	
	# Make sure the class exists (no reason it shouldn't)
	assert(!type_class.is_empty(), ("type_class is empty, other params: type=%s, type_script=%s")\
	 % [type, type_script])
	
	# For built in objects, we can just return the class name. Those won't change, and if the do
	# then other parts of projects will break too (not our problem to worry about)
	# Can omit the type since if "c" is present, we know it's TYPE_OBJECT
	if type_script == null:
		return {
			"c": type_class,
		}
	
	# For custom classes, we'll resolve the JSONObjectConfig for that type. It HAS to exist
	# for elements to be serialized anyways, so if it doesn't an error will be thrown.
	
	assert(type_script is Script, "type_script script (%s) not of type Script" % type_script)
	assert(!type_script.get_global_name().is_empty(), ("type_script (%s) does not have a " + \
	"class_name defined, type_script.path=%s") % [type_script, type_script.resource_path])
	
	var config: JSONObjectConfig = impl.object_config_registry.get_config_by_class(type_script.get_global_name())
	assert(config != null, "type_script (%s)'s class (%s) does not have a JSONObjectConfig associated with it" \
	% [type_script, type_script.get_global_name()])
	
	return {
		"i": config.id, # ID of the config, can resolve class name & base type from this
	}
