## A registry of all [JSONObjectConfig]s. Create an instance of this file
## in your project's directory and set it's path in Project Settings
## under (nethlib/modules/json_object_config_registry). Add configs to
## [member _configs] so that the JSONSerialization can recognize them.
@tool
class_name JSONObjectConfigRegistry extends Resource

## Default configs built into Godot-JSON. Nothing here yet but added the framework
## in case I decide to expand upon this more.
static var _default_configs: Array[JSONObjectConfig]

## User (your) configurations to be registered to the global [JSONSerializationImpl]. 
## ALL configs need to be registered in order to deserialize objects. It is important
## to not remove [JSONObjectConfig]s without sanitizing stored JSON data that was serialized
## by those config(s), as the [member JSONObjectConfig.id] is stored in the JSON data
## to determine how to deserialize it. So removing its conifg will cause errors.
@export var _user_configs: Array[JSONObjectConfig]:
	set(value):
		_user_configs = value
		if !Engine.is_editor_hint():
			_populate_dictionaries(_user_configs, "_user_configs")
			_configs.append_array(_user_configs)

var _configs: Array[JSONObjectConfig]

## [member JSONObjectConfig.id]:[JSONObjectConfig]
var _configs_by_id: Dictionary

## [member JSONObjectConfig.for_class]:[JSONObjectConfig]
var _configs_by_class: Dictionary

func _init() -> void:
	if !Engine.is_editor_hint():
		_populate_dictionaries(_default_configs, "_default_configs")
		_configs.append_array(_default_configs)


## Returns true if the [param config] is registered, false if not.
func has_config(config: JSONObjectConfig) -> bool:
	return _configs.has(config)


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.for_class] as [param _class]
## exists, false if not. For use at runtime only, in the editor use [method editor_has_class].
func has_class(_class: StringName) -> bool:
	assert(!Engine.is_editor_hint(), "use editor_has_class() in Editor")
	return _configs_by_class.has(_class)


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.for_class] as [param _class]
## exists, false if not. For use in the editor only, at runtime use [method has_class].
func editor_has_class(_class: StringName) -> bool:
	for config: JSONObjectConfig in _default_configs:
		if config.for_class == _class:
			return true
	for config: JSONObjectConfig in _user_configs:
		if config.for_class == _class:
			return true
	return false


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.id] as [param id] exists,
## false if not. For use at runtime only, in the editor use [method editor_has_id].
func has_id(id: StringName) -> bool:
	assert(!Engine.is_editor_hint(), "use editor_has_id() in Editor")
	return _configs_by_id.has(id)


## Returns true if a [JSONObjectConfig] with [member JSONObjectConfig.id] as [param id] exists,
## false if not. For use in the editor only, at runtime use [method has_id].
func editor_has_id(id: StringName) -> bool:
	assert(Engine.is_editor_hint(), "use has_id() at Runtime")
	for config: JSONObjectConfig in _default_configs:
		if config.id == id:
			return true
	for config: JSONObjectConfig in _user_configs:
		if config.id == id:
			return true
	return false


## Returns the [JSONObjectConfig] with [member JSONObjectConfig.for_class] of [param _class], 
## or null if one does not exist. For use at runtime only.
func get_config_by_class(_class: StringName) -> JSONObjectConfig:
	assert(!Engine.is_editor_hint(), "get_config_by_class not for use in the Editor")
	return _configs_by_class.get(_class, null)


## Returns the [JSONObjectConfig] with [member JSONObjectConfig.id] of [param id], 
## or null if one does not exist. For use at runtime only.
func get_config_by_id(id: StringName) -> JSONObjectConfig:
	assert(!Engine.is_editor_hint(), "get_config_by_id not avialable in editor")
	return _configs_by_id.get(id, null)


## Adds the [param config] during runtime, will not affect the underlying
## [member _user_configs] or [member _default_configs], and will not be
## saved to this resource (will need to be manually called each time the engine/game
## starts up).
func add_config(config: JSONObjectConfig) -> void:
	assert(!Engine.is_editor_hint(), "add_config not avialable in editor")
	assert(config != null, "config is null")
	assert(!_configs.has(config), "config (%s) already exists" % config)
	assert(!config.id.is_empty(), "config.id empty for config (%s)" % config)
	assert(!_configs_by_id.has(config.id), "config with id (%s) already exists" % config.id)
	assert(!config.for_class.is_empty(), "config.for_class empty for config (%s)" % config)
	assert(!_configs_by_class.has(StringName(config.for_class)), 
	"config for class (%s) already exists" % config.for_class)
	
	_configs.append(config)
	_configs_by_id[config.id] = config
	_configs_by_class[StringName(config.for_class)] = config


## Removes [param config] during runtime, will not affect the underlying
## [member _user_configs] or [member _default_configs], and will not be
## saved to this resource (will need to be manually called each time the engine/game
## starts up).
func remove_config(config: JSONObjectConfig) -> void:
	assert(!Engine.is_editor_hint(), "remove_config not avialable in editor")
	assert(config != null, "config is null")
	_configs.erase(config)
	_configs_by_id.erase(config.id)
	_configs_by_class.erase(StringName(config.for_class))


## A version of [method duplicate] designed to be used when instantiating new
## [JSONSerializationImpl]s. Duplicates internal arrays/dictionaries but
## keeps the objects in them the same instances.
func copy() -> JSONObjectConfigRegistry:
	assert(!Engine.is_editor_hint(), "copy() not supported in the Editor")
	var registry: JSONObjectConfigRegistry = JSONObjectConfigRegistry.new()
	registry._configs = _configs.duplicate(false)
	registry._configs_by_id = _configs_by_id.duplicate(false)
	registry._configs_by_class = _configs_by_class.duplicate(false)
	return registry


func _populate_dictionaries(array: Array[JSONObjectConfig], array_name: String) -> void:
	assert(!Engine.is_editor_hint(), "_populate_dictionaries not supported in the Editor")
	# Add to dictionaries
	for config: JSONObjectConfig in array:
		if config == null:
			push_warning("%s has a null element" % array_name)
			continue
		
		if config.id.is_empty():
			push_warning("config.id is empty for config (%s) of array (%s), can't register it" \
			% [config, array_name])
			continue
		
		if _configs_by_id.has(config.id):
			push_warning("Duplicate config ids found in array (%s): (%s), skipping config (%s)" \
			% [array_name, config.id, config])
			continue
		
		if config.for_class.is_empty():
			push_warning("config.for_class is empty for config (%s) of array (%s), skipping config" \
			% [config, array_name])
			continue
		
		if _configs_by_class.has(StringName(config.for_class)):
			push_warning("Duplicate configs for class: (%s) of array (%s), skipping config (%s)" \
			% [config.for_class, array_name, config])
			continue
		
		_configs_by_id[config.id] = config
		_configs_by_class[StringName(config.for_class)] = config
