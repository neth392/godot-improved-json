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
		# Set script if it exists & isn't already set (for_class was manually set)
		# Then return from this setter as set_for_class_by_script will call it again
		if Engine.is_editor_hint() && !value.is_empty():
			var script_path: String = GodotJSONUtil.get_script_path_from_class_name(value)
			if !script_path.is_empty():
				var script: Script = load(script_path) as Script
				if script != null && script != set_for_class_by_script:
					set_for_class_by_script = script
					return
			
		if set_for_class_by_script != null && !set_for_class_by_script.get_global_name().is_empty():
			# Derive class from script
			for_class = set_for_class_by_script.get_global_name()
		else:
			# Set class by input
			for_class = value
		
		# Autopopulate ID if empty
		if Engine.is_editor_hint() && id.is_empty() && !for_class.is_empty():
			id = for_class
		
		_editor_update()
		notify_property_list_changed()
		
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

## The [JSONInstantiator] used anytime an object of this type is being deserialized
## but the property's assigned value is null and thus an instance needs to be created.
## See that class's docs for more info.
@export var instantiator: JSONInstantiator

## Can be set so that the [member properties] of another config are included
## when serializing/deserializing. Useful when creating configs for objects within
## the same class hierarchy.
## [br]NOTE: If any [JSONProperty] in [member properties] contains the same
## [member JSONProperty.property_name] as any property in the extended config, it will
## override the one in the extended config. Can be useful to disable properties or
## handle missing properties differently.
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

@export_group("Resource File Instances", "json_res_")

## If true, any [Resource] with class [member for_class] who has a [member Resource.resource_path] 
## will be handled differently than normal objects. When serialized to JSON, either the 
## resource path or [member JSONResourceFileInstance.id] is included (see below options).
## When deserialized, that instance of the resource will be loaded from the file &
## used instead of creating a new instance of the resource. This is to ensure that
## resource instances == each other properly when references to the same instance are serialized
## in multiple locations across the project.
## [br]If false, this system is not used and they are serialized & deserialized like any other object.
@export var json_res_maintain_resource_instances: bool = false:
	set(value):
		json_res_maintain_resource_instances = value
		notify_property_list_changed()

## If true, [member Resource.resource_path] is included in the resource's JSON. This can
## result in errors if that path is moved & an attempt is made to load the JSON with
## the old path. This also means that ALL resources of this type who have a resource path
## will be saved & loaded via this method, instead of a new instance being created.
## [br]If false, [member json_res_instances] is used (see those docs for more info).
## [br][code]false[/code] by default to prevent breakages by changing resource paths.
@export var json_res_use_resource_path: bool = false:
	set(value):
		json_res_use_resource_path = value
		notify_property_list_changed()

## If true, resources which have a [member Resource.resource_path] will
## include [member properties] & their values when serializing & deserializing.
## Recommended to be false as usually a [Resource] saved to a .tres file will
## not need those properties serialized, but this is provided to keep this system
## flexible. If you need this on a per-resource basis, use [member json_res_resource_file_instances]
## instead and disable/uncheck [member json_res_use_resource_path].
@export var json_res_include_properties_in_file_instances: bool = false:
	set(value):
		json_res_include_properties_in_file_instances = value
		notify_property_list_changed()

## Array of [JSONResourceFileInstance]s that must contain every [Resource] file instance
## that can be used in place of constructing a new resource.
##[br]WARNING: Changes made to this array at runtime will not be reflected as
## it is converted into an internal [Dictionary] at startup for efficiency.
@export var json_res_resource_file_instances: Array[JSONResourceFileInstance]:
	set(value):
		json_res_resource_file_instances = value
		if !Engine.is_editor_hint():
			_populate_resource_dictionaries(json_res_resource_file_instances)
		else:
			_editor_update()

## A visual property to show you if this config is properly registered in the 
## [JSONObjectConfigRegistry] or not.
var registered: bool:
	get():
		return JSONSerialization.object_config_registry.has_config(self)
	set(value):
		assert(false, "registered is READ ONLY")

## Internal flag to prevent [member id] from changing at runtime.
var _id_initialized: bool = false

## Internal dictionary set at runtime, format:
## [member JSONResourceFileInstance.id]:[JSONResourceFileInstance]
var _file_instances_by_path: Dictionary
var _file_instance_by_id: Dictionary

func _validate_property(property: Dictionary) -> void:
	# Make registered readonly
	if property.name == "registered":
		property.usage = PROPERTY_USAGE_READ_ONLY | PROPERTY_USAGE_EDITOR
		return
	
	# Make for_class read only if set by script
	if property.name == "for_class" && set_for_class_by_script != null:
		property.usage = property.usage | PROPERTY_USAGE_READ_ONLY
		return
	
	# Hide resource related properties if not of type resource
	if (property.name == "json_res_maintain_resource_instances" \
	or property.name == "json_res_use_resource_path" \
	or property.name == "json_res_resource_file_instances" \
	or property.name == "json_res_include_properties_in_file_instances") \
	and !is_resource():
		property.usage = PROPERTY_USAGE_NONE
		return
	
	# Make resource properties read only if maintain instance feature not enabled
	if !json_res_maintain_resource_instances \
	and (property.name == "json_res_use_resource_path" \
	or property.name == "json_res_resource_file_instances" \
	or property.name == "json_res_include_properties_in_file_instances"):
		property.usage |= PROPERTY_USAGE_READ_ONLY
		return
	
	# Make json_res_include_properties_in_file_instances only show if json_res_use_resource_path is true
	if property.name == "json_res_include_properties_in_file_instances" && !json_res_use_resource_path:
		property.usage = PROPERTY_USAGE_STORAGE
		return
	
	# Make json_res_resource_file_instances only show if json_res_use_resource_path is false
	if property.name == "json_res_resource_file_instances" && json_res_use_resource_path:
		property.usage = PROPERTY_USAGE_STORAGE
		return


## Returns a new [Array] of all [JSONProperty]s of this instance and [member extend_other_config]
## (if it isn't null).
func get_properties_extended() -> Array[JSONProperty]:
	var extended: Array[JSONProperty] = []
	var names: Dictionary = {}
	
	# Add these properties
	for property: JSONProperty in properties:
		names[property.property_name] = true
		extended.append(property)
	
	# Add extended properties (unless overridden)
	if extend_other_config != null:
		for property: JSONProperty in extend_other_config.get_properties_extended():
			if names.has(property.property_name): # Skip if it was overridden in this config
				continue
			extended.append(property)
	
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


## Returns true if this [JSONObjectConfig] is for a resource.
func is_resource() -> bool:
	if set_for_class_by_script != null:
		return set_for_class_by_script.get_instance_base_type() == &"Resource"
	if !for_class.is_empty():
		return ClassDB.is_parent_class(StringName(for_class), &"Resource")
	return false


## Populates the internal [member _file_instances_by_path] from the [param array].
## Only available at runtime, not in the editor.
func _populate_resource_dictionaries(array: Array[JSONResourceFileInstance]) -> void:
	assert(!Engine.is_editor_hint(), "method not supported in the Editor")
	_file_instances_by_path.clear()
	
	# Keep track of ids to ensure no duplicates
	for instance: JSONResourceFileInstance in array:
		if instance == null:
			push_warning("JSONObjectConfig(%s) has a null value in json_res_file_instances" \
			 % id)
			continue
		
		assert(!instance.id.is_empty(), ("json_res_file_instances contains a JSONResourceFileInstance " + \
		"with an empty ID for JSONObjectConfig(%s)") % id)
		
		assert(instance.resource != null, ("JSONResourceFileInstance(%s) does not have a resource " + \
		"set, found in JSONObjectConfig(%s)") % [instance.id, id])
		
		assert(!instance.path_to_resource.is_empty(), ("JSONResourceFileInstance(%s) has an " + \
		"empty path, found in JSONObjectConfig(%s)") % [instance.id, id])
		
		assert(!_file_instances_by_path.has(instance.path_to_resource), ("duplicate " + \
		"resource paths (%s) found in json_res_file_instances of JSONObjectConfig(%s)") \
		% [instance.path_to_resource, id])
		
		assert(!_file_instance_by_id.has(instance.id), ("duplicate JSONResourceFileInstance.ids " + \
		"(%s) found in json_res_file_instances of JSONObjectConfig(%s)") % [instance.id, id])
		
		_file_instance_by_id[instance.id] = instance
		_file_instances_by_path[instance.path_to_resource] = instance


func _editor_update() -> void:
	if !Engine.is_editor_hint():
		return
	
	for property: JSONProperty in properties:
		if property != null:
			if property._editor_class_name != for_class:
				property._editor_class_name = for_class
			if property._editor_script != set_for_class_by_script:
				property._editor_script = set_for_class_by_script
	
	for instance: JSONResourceFileInstance in json_res_resource_file_instances:
		if instance != null:
			instance._editor_type_hint = for_class


func _to_string() -> String:
	return "JSONObjectConfig(id=%s,for_class=%s)" % [id, for_class]
