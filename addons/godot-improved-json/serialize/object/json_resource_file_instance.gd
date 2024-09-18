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
@export var id: String:
	set(value):
		if !Engine.is_editor_hint() && _id_initialized:
			assert(false, "can't change JSONResourceFileInstance.id at runtime")
		id = value
		_id_initialized = true

## The resource instance this represents. Do not create a sub resource here, instead
## drag one from your file system. Must be of the same class as defined in the [JSONObjectConfig].
@export var resource: Resource:
	set(value):
		if value != null:
			assert(!value.resource_path.is_empty(), ("resource (%s)'s path is empty, this feature" + \
			"is only designed for resources saved to a file") % value)
			
			assert(!value.resource_path.contains(resource_path), ("resource (%s) was created" + \
			"as a sub-resource of this JSONResourceFileInstance. That is not supported. " + \
			"Drag & drop an existing resource file from the filesystem to this property.") \
			% value)
		
		resource = value

## Internal flag to prevent [member id] from changing at runtime.
var _id_initialized: bool = false

## Returns the [member Resource.resource_path] of [member resource], or an
## empty string if [member resource] is null.
func get_resource_path() -> String:
	return "" if resource == null else resource.resource_path
