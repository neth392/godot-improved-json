## Instantiator that creates an instance from a [GDScript]
@tool
class_name JSONScriptInstantiator extends JSONInstantiator

## The [GDScript] to be instantiated.
@export var gd_script: GDScript:
	set(value):
		if value != null:
			var error_msg: String = _can_instantiate_script(value)
			assert(error_msg.is_empty(), error_msg)
		gd_script = value


func _can_instantiate() -> bool:
	return _can_instantiate_script(gd_script).is_empty()


func _can_instantiate_script(_script: GDScript) -> String:
	if _script == null:
		return "gd_script is null"
	for method: Dictionary in _script.get_script_method_list():
		# The first method named _init is the constructor used by .new()
		if method.name == "_init":
			if method.args.size() != method.default_args.size():
				return "all _init(...) arguments must have default values"
			break
	return ""


func _instantiate() -> Object:
	assert(gd_script != null, "gd_script is null")
	return gd_script.new()
