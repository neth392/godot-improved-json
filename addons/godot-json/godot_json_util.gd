## Some utilities from my NethLib project
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
