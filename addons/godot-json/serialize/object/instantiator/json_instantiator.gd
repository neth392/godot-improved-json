## Used to create instances of [Object]s when they are being deserialized but
## there is no instance to deserialize into. Instead of storing data on how to 
## instantiate objects in the serialized data, this way of doing things is much
## safer as it prevents breakages from refactoring of file paths, class name changes,
## etc.
@tool
class_name JSONInstantiator extends Resource

## Returns true if the [param property] and [param serialized] can be instantiated,
## false if not.
func _can_instantiate() -> bool:
	return false


## Instantiates & returns a new [Object] instance.
func _instantiate() -> Object:
	assert(false, "_instantiate not overridden")
	return null
