## A serializer for a specific variant type (or several types in some cases)
@tool
class_name Serializer extends Resource


## The ID of this [Serializer]
var id: String:
	get():
		var id: Variant = _get_id()
		assert(id != null, "_get_id() returned null")
		return str(id) # Convert to string
	set(value):
		assert(false, "override _get_id() to change the ID")


var _can_deserialize_into: bool = SerializationUtil.get_method_count(get_script(), 
"_deserialize_into") > 1


## Returns true if [method _deserialize_into] has been overridden by a child class,
## false if not. Override this for custom implementations.
func can_deserialize_into() -> bool:
	return _can_deserialize_into


## Must be overridden to return the ID of this [Serializer], to be stored in the JSON to determine
## which [Serializer] to use when deserializing. Returned [Variant] will be converted to a [String]
## by [member id]'s getter.
func _get_id() -> Variant:
	assert(false, "_get_id() not implemented")
	return null


## Parses [param variant] into a [Variant] which must be able to be
## deserialized by [method _deserialize_into].
## [param impl] is the Serialization implementation being used.
func _serialize(instance: Variant, impl: SerializationImpl) -> Variant:
	assert(false, "_serialize not implemented for serializer id (%s)" % id)
	return {}


## Deserializes the [param serialized] by constructing a new instance of the
## supported type. The newly created type is then returned.
## [param impl] is the Serialization implementation being used.
func _deserialize(serialized: Variant, impl: SerializationImpl) -> Variant:
	assert(false, "_deserialize not implemented for serializer id (%s)" % id)
	return null


## Deserializes [i]into[/i] the specified [param instance] from the [param serialized].
## [param impl] is the Serialization implementation being used.
func _deserialize_into(serialized: Variant, instance: Variant, impl: SerializationImpl) -> void:
	assert(false, "_deserialize_into not implemented for serializer id (%s)" % id)


func _to_string() -> String:
	return "Serializer(%s)" % id
