## A configuration containing specifications on how to serialize & deserialize a
## specific type of [Object]. Must be registered to the project's [JSONObjectConfigRegistry]
## to be used.
@tool
class_name JSONObjectConfig extends Resource

## The ID of this [JSONObjectConfig], stored in the serialized data to detect
## how to deserialize an instance of an object.
## [br]WARNING: Changing this property can break existing save data. Set it once
## and keep it the same. Can not be changed at runtime.
@export var id: StringName:
	set(value):
		if !Engine.is_editor_hint() && _id_initialized:
			assert(false, "can't change JSONObjectConfig.id at runtime")
		id = value
		_id_initialized = true

## The class this config is meant to parse. If [member set_for_class_by_script] is used,
## this property becomes read only & is derived from that script.
@export_custom(PROPERTY_HINT_TYPE_STRING, &"Object") var for_class: String:
	set(value):
		if set_for_class_by_script != null && !set_for_class_by_script.get_global_name().is_empty():
			for_class = set_for_class_by_script.get_global_name()
		else:
			for_class = value
		_editor_update()
	get():
		if set_for_class_by_script != null && !set_for_class_by_script.get_global_name().is_empty():
			return set_for_class_by_script.get_global_name()
		return for_class


## Sets [member for_class] based on the class_name of this script. Highly recommended as it
## preserves any name change in the script.
@export var set_for_class_by_script: Script:
	set(value):
		if value == null: # Null script
			set_for_class_by_script = null
			for_class = ""
		elif value != null && value.get_global_name().is_empty(): # Script w/ no name
			push_warning("Can't use this script; no class_name defined for script: %s" % value.resource_path)
			set_for_class_by_script = null
			for_class = ""
		else: # Not null, script w/ name
			set_for_class_by_script = value
			for_class = set_for_class_by_script.get_global_name()
		notify_property_list_changed()

## The [JSONInstantiator] used anytime an object of this type is being deserialized
## but the property's assigned value is null and thus an instance needs to be created.
## See that class's docs for more info.
@export var instantiator: JSONInstantiator

## Can be set so that the [member properties] of another config are included
## when serializing/deserializing. Useful when creating configs for objects within
## the same class hierarchy.
@export var extend_other_config: JSONObjectConfig:
	set(value):
		if extend_other_config != null && extend_other_config.extend_other_config == self:
			push_warning("Can't set extend_other_config to %s as it causes a circular reference" % value)
			return
		extend_other_config = value

## The [JSONProperty]s that are to be serialized. Properties with [member JSONProperty.enabled]
## as false are ignored. The order of this array is important as it determines in which order
## properties are serialized in.
## [br]Format: [member JSONProperty.json_key]:[JSONProperty]
@export var properties: Array[JSONProperty]:
	set(value):
		properties = value
		_editor_update()
		notify_property_list_changed()

## A visual property to show you if this config is properly registered in the 
## [JSONObjectConfigRegistry] or not.
var registered: bool:
	get():
		return JSONSerialization.object_config_registry.has_config(self)
	set(value):
		assert(false, "registered is READ ONLY")

## Internal flag to prevent [member id] from changing at runtime.
var _id_initialized: bool = false


func _validate_property(property: Dictionary) -> void:
	# Make registered readonly
	if property.name == "registered":
		property.usage = PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR
	
	# Make for_class read only if set by script
	if property.name == "for_class" && set_for_class_by_script != null:
		property.usage = property.usage | PROPERTY_USAGE_READ_ONLY


func _editor_update() -> void:
	if !Engine.is_editor_hint():
		return
	for property: JSONProperty in properties:
		if property != null:
			property._editor_class_name = for_class
			property._editor_script = set_for_class_by_script


## Returns a new [Array] of all [JSONProperty]s of this instance and [member extend_other_config]
## (if it isn't null).
func get_properties_extended() -> Array[JSONProperty]:
	var extended: Array[JSONProperty] = []
	extended.append_array(properties)
	if extend_other_config != null:
		extended.append_array(extend_other_config.get_properties_extended())
	return extended


## Returns the [Script] associated with the class this instance represents, or null
## if one does not exist (for built in types). If [member set_for_class_by_script] is
## not used, the script's path is resolved from [ProjectSetting]s and [method load]
## is called to attempt to load the script.
func get_class_script() -> Script:
	if set_for_class_by_script != null:
		return set_for_class_by_script
	var script_path: String = GodotJSONUtil.get_script_path_from_class_name(for_class)
	if script_path.is_empty():
		return null
	return load(script_path) as Script


func _to_string() -> String:
	return "JSONObjectConfig(id=%s,for_class=%s)" % [id, for_class]
