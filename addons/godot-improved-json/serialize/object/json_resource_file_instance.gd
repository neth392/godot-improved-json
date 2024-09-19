## Represents a global resource file in the project so that resource instances
## saved to a file can be properly deserialized as that exact instance from JSON 
## if any reference to that instance was originally serialized. [member id] is stored
## in JSON, and when that id is found in JSON instead of creating a new instance, [member resource]
## is set to the property.
@tool
class_name JSONResourceFileInstance extends Resource

## The ID of this resource file. Stored in JSON in place of the [member resource]'s
## [member Resource.resource_path] so that the resource's path can change without breaking
## stored JSON.
@export var id: StringName:
	set(value):
		if !Engine.is_editor_hint() && _id_initialized:
			assert(false, "can't change JSONResourceFileInstance.id at runtime")
		id = value
		_id_initialized = true

## The resource instance this represents. Do not create a sub resource here, instead
## drag one from your file system. Must be of the same class as defined in the [JSONObjectConfig].
@export var resource: Resource:
	set(value):
		# Behavior in game
		if !Engine.is_editor_hint():
			assert(value != null, "resource is null for JSONResourceFileInstance(%s)" % id)
			resource = value
			return
		
		# Behavior when set from path_to_resource in editor
		if !_set_other_property:
			resource = value
			_set_other_property = true
			return
		
		# Default behavior in editor
		if value != null:
			assert(!value.resource_path.is_empty(), ("resource (%s)'s path is empty, this feature" + \
			"is only designed for resources or sub resources saved to a file") % value)
			if id.is_empty():
				id = value.resource_path.get_file()
		
		_set_other_property = false
		resource = value
		path_to_resource = "" if resource == null else resource.resource_path
		_set_other_property = true


## Alternative to setting [member resource]. Supports sub-resources as long as
## you enter the correct path. Must be manually updated if the sub resource path
## changes though.
@export var path_to_resource: String:
	set(value):
		# Behavior when set from resource or in game
		if !_set_other_property || !Engine.is_editor_hint():
			path_to_resource = value
			_set_other_property = true
			return
		
		_set_other_property = false
		path_to_resource = value
		if value.is_empty():
			resource = null
		elif ResourceLoader.exists(path_to_resource):
			resource = load(path_to_resource)
			if id.is_empty():
				id = path_to_resource.get_file()
		
		_set_other_property = true

## If true, [JSONProperty]s defined in the [JSONObjectConfig] are serialized & also
## deserialized and set to [member resource]. If false, the properties are ignored.
## Usually false since this feature was meant for resource files that are static to a project,
## & not meant to dynamically change. But this is here for flexibility, ultimately up to you.
@export var include_properties: bool = false

# Internal flag to keep resource & path_to_resource from causing a stack overflow
# by infinitely updating each other
var _set_other_property: bool = true

# Internal flag to prevent [member id] from changing at runtime.
var _id_initialized: bool = false

# Internal class name used in the property hint of resource
var _editor_type_hint: StringName

func _validate_property(property: Dictionary) -> void:
	if property.name == "resource" && !_editor_type_hint.is_empty():
		property.hint_string = _editor_type_hint


func _to_string() -> String:
	return "JSONResourceFileInstance(id=%s,path_to_resource=%s)" % [id, path_to_resource]
