## Conducts serialization & deserialization of all types. Stores [JSONSerializer]s and
## [JSONObjectConfig]s.
@tool
class_name JSONSerializationImpl extends Node

## Parameter used in [method JSON.stringify]. From the Godot docs: The indent 
## parameter controls if and how something is indented; its contents will be 
## used where there should be an indent in the output. Even spaces like 
## "   " will work. \t and \n can also be used for a tab indent, or to make 
## a newline for each indent respectively.
@export_storage var indent: String = ""

## Parameter used in [method JSON.stringify]. Initially to set to false to preserve 
## serialized [Dictionary] order. There is no description of this parameter in the
## Godot docs, but I believe that it just sorts the JSON keys in a particular order.
## Usually that shouldn't matter and this should be left false.
@export_storage var sort_keys: bool = false

## Parameter used in [method JSON.stringify], from the Godot docs: If full_precision is true, 
## when stringifying floats, the unreliable digits are stringified in addition to the 
## reliable digits to guarantee exact decoding.
@export_storage var full_precision: bool = false

## Parameter used in [method JSON.parse], from the Godot docs: The optional keep_text 
## argument instructs the parser to keep a copy of the original text. 
## This text can be obtained later by using the get_parsed_text() function 
## and is used when saving the resource (instead of generating new text from data).
@export_storage var keep_text: bool = false

## [member JSONSerializer.id]:[JSONSerializer]
var _serializers: Dictionary = {}
var _can_deserialize_into: Dictionary = {}

## The user's [JSONObjectConfigRegistry] to allow adding [JSONObjectConfig]s via
## the inspector.
var object_config_registry: JSONObjectConfigRegistry = JSONObjectConfigRegistry.new():
	set(value):
		object_config_registry = value if value != null else JSONObjectConfigRegistry.new()

# Internal cache of native serializers used by others to prevent unnecessary dictionary lookups
var _color: JSONSerializer
var _vector2: JSONSerializer
var _vector2i: JSONSerializer
var _vector3: JSONSerializer
var _vector4: JSONSerializer
var _basis: JSONSerializer

# Internal JSON object & errors
var _json: JSON = JSON.new()

# DO NOT MAKE THIS TRUE. In unit testing if this is true I manually add 1 to the reference counter
# when testing the WeakRef code. This WILL break your game if you mess with this.
# It is so serious that I have broken the holy variable naming conventions for this one.
var _test_mode_DO_NOT_TOUCH: bool = false:
	set(_value):
		if !OS.is_debug_build():
			push_error("Do NOT change this. This is for Improve JSON's own unit tests.")
		_test_mode_DO_NOT_TOUCH = _value

## Returns the underlying [JSON] instance in use by this instance.
func get_json() -> JSON:
	return _json


## Retunrs true if [param variant] is supported by a [JSONSerializer], false if not.
func is_serializiable(variant: Variant) -> bool:
	return is_type_serializable(typeof(variant))


## Returns true if the [param type] is supported by a [JSONSerializer], false if not.
func is_type_serializable(type: Variant.Type) -> bool:
	return _serializers.has(str(type))


## Adds the [param serializer].
func add_serializer(serializer: JSONSerializer) -> void:
	assert(serializer != null, "serializer is null")
	assert(!_serializers.has(serializer.id), "a serializer with id (%s) already exists" % serializer.id)
	_serializers[serializer.id] = serializer
	_can_deserialize_into[serializer.id] = serializer.can_deserialize_into()


## Removes the [param serializer], returning true if removed, false if not.
func remove_serializer(serializer: JSONSerializer) -> bool:
	assert(serializer != null, "serializer is null")
	_can_deserialize_into.erase(serializer.id)
	return _serializers.erase(serializer.id)


## Returns true if the [param type] has a [JSONSerializer] that can be deserialized_into,
## false if not.
func can_deserialize_into_type(type: Variant.Type) -> bool:
	return _can_deserialize_into.get(str(type), false)


## Returns the [JSONSerializer] with the [param id], or null if one does not exist.
func get_serializer_for_type(type: Variant.Type) -> JSONSerializer:
	return _serializers.get(str(type))


## Returns the [JSONSerializer] for use with deserializing the [param wrapped_value].
## [param serialize] must be a [Dictionary] wrapped by [JSONSerialization].
## An assertion is called so that in debug mode if no [JSONSerializer] is found for the 
## [param wrapped_value], an error is thrown. In release mode an error will be thrown
## as well, but from trying to access a missing key from the internal [member _serializers]
## dictionary.
func get_deserializer(wrapped_value: Dictionary) -> JSONSerializer:
	assert(wrapped_value.has("i"), "'i' key not found in wrapped_value (%s)" % wrapped_value)
	assert(_serializers.has(wrapped_value.i), ("no JSONSerializer with id (%s) found for " + \
	"wrapped_value(%s)") % [wrapped_value.i, wrapped_value])
	
	return _serializers[wrapped_value.i]


## Serializes the [param variant] into a wrapped [Dictionary] (see [method wrap_value]) 
## that can be safely stored via JSON & deserialized.
func serialize(variant: Variant) -> Dictionary:
	# str(variant) needed as some types such as RID will not work w/o it for some reason
	assert(is_serializiable(variant), "variant (%s) of type (%s) not supported by any JSONSerializer" \
	% [str(variant), typeof(variant)])
	
	var serializer: JSONSerializer = get_serializer_for_type(typeof(variant))
	assert(serializer != null, "get_serializer_for_type(typeof(%s)) returned null" % str(variant))
	var serialized: Variant = serializer._serialize(variant, self)
	
	return _wrap_value(serializer, serialized)


## Deserializes the [param wrapped_value] and creates & returns a new instance of the type.
func deserialize(wrapped_value: Dictionary) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null, must be a Dictionary")
	
	var serializer: JSONSerializer = get_deserializer(wrapped_value)
	assert(serializer != null, "get_deserializer(%s) returned null" % wrapped_value)
	var unwrapped_value: Variant = _unwrap_value(wrapped_value)
	
	return serializer._deserialize(unwrapped_value, self)


## Deserializes the [param wrapped_value] into the specified [param instance]. The [param instance]
## can not be null and its [JSONSerializer] must support [method JSONSerializer._deserialize_into],
## which currently is only supported for [Array], [Dictionary], and [Object].
func deserialize_into(wrapped_value: Dictionary, instance: Variant) -> void:
	assert(instance != null, "instance is null, can't deserialize into a null instance")
	
	var serializer: JSONSerializer = get_serializer_for_type(typeof(instance))
	assert(serializer != null, "get_serializer_for_type(typeof(%s)) returned null" % instance)
	assert(serializer.can_deserialize_into(), "")
	
	# In debug, ensure serializers match up from instance type & wrapped type
	if OS.is_debug_build():
		var wrapped_serializer: JSONSerializer = get_deserializer(wrapped_value)
		assert(serializer == wrapped_serializer, ("serializer (%s) of instance (%s) " + \
		"does not match serializer (%s) of wrapped_value (%s)") % [serializer, instance, \
		 wrapped_serializer, wrapped_value])
	
	var unwrapped_value: Variant = _unwrap_value(wrapped_value)
	serializer._deserialize_into(wrapped_value, instance, self)


## Helper function that calls [method serialize] with the [param variant],
## then passing that varaint & other parameters into [method JSON.stringify], returning
## that value.
func stringify(variant: Variant) -> String:
	var serialized: Dictionary = serialize(variant)
	return _json.stringify(serialized, indent, sort_keys, full_precision)


## Helper function that calls [method JSON.parse] with [param wrapped_json_string], then
## sends the resulting [Variant] to [method deserialize], returning that value.
## [br][param wrapped_json_string] is what is returned by [method serialize], and
## [method stringify].
func parse(wrapped_json_string: String) -> Variant:
	var parsed: Variant = _parse(wrapped_json_string)
	return deserialize(parsed as Dictionary)


## Helper function to call [method JSON.parse_string] with [param wrapped_json_string], then
## sends the resulting [Variant] and [param instance] to [method deserialize_into].
## [br][param wrapped_json_string] is what is returned by [method serialize], and
## [method stringify].
func parse_into(instance: Variant, wrapped_json_string: String) -> void:
	var parsed: Variant = _parse(wrapped_json_string)
	deserialize_into(instance, parsed as Dictionary)


## Internal helper function for [method parse] and [method parse_into].
func _parse(wrapped_json_string: String) -> Variant:
	# TODO better error handling?
	var error: Error = _json.parse(wrapped_json_string, keep_text)
	assert(error == OK, "JSON error: line=%s,message=%s" % [_json.get_error_line(), _json.get_error_message()])
	assert(_json.data is Dictionary, "json.parse() result (%s) not of type Dictionary for wrapped_json_string %s"\
	 % [_json.data, wrapped_json_string])
	return _json.data


## Constructs & returns a new JSON-parsable [Dictionary] containing a "i" key
## of [member JSONSerializer.id] from the [param serializer], and a
## "v" of [param serialized]. Will only be truly JSON parsable if the [param serialized]
## is natively supported by Godot's JSON.
func _wrap_value(serializer: JSONSerializer, serialized: Variant) -> Dictionary:
	return {
		"i": serializer.id,
		"v": serialized,
	}


## Unwraps & returns the value from the [param wrapped_value] assuming it was created
## via [method wrap_value].
func _unwrap_value(wrapped_value: Dictionary) -> Variant:
	assert(wrapped_value != null, "wrapped_value is null")
	assert(wrapped_value.has("v"), "wrapped_value (%s) does not have 'v' key" % wrapped_value)
	return wrapped_value.v
