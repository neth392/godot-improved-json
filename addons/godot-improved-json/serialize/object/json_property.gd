## Represents a property within an [Object] that is configured for
## JSON serialization.
@tool
class_name JSONProperty extends Resource

## How to handle properties missing in objects or serialized objects.
enum IfMissing {
	## Properties misssing from an Object are ignored.
	IGNORE,
	## Properties missing from an Object trigger console warnings in debug mode only.
	WARN_DEBUG,
	## Properties missing from an Object trigger errors via assertions in debug mode only.
	ERROR_DEBUG,
}

## The key of the property in the JSON file. 
## [br]WARNING: Changing this property will break existing data stored in json. 
@export var json_key: StringName

## The name of the property in the [Object].
@export var property_name: String:
	set(value):
		property_name = value
		if Engine.is_editor_hint() && json_key.is_empty() && !property_name.is_empty():
			json_key = property_name
		notify_property_list_changed()

@export_group("Advanced")

## If this property should be serialized or not.
@export var enabled: bool = true

## If false, null values found in serializing and/or deserializing will trigger
## an error in debug mode. If true, null values are serialized as null with no 
## warning or error.
@export var allow_null: bool = true

## How to handle properties missing from an [Object] when serializing it.
@export var if_missing_in_object_serialize: IfMissing = IfMissing.ERROR_DEBUG

## How to handle properties missing from serialized json when deserialzing an Object.
@export var if_missing_in_json: IfMissing = IfMissing.ERROR_DEBUG

## How to handle properties that exist in serialized data but are missing from
## the [Object] being deserialized.
@export var if_missing_in_object_deserialize: IfMissing = IfMissing.ERROR_DEBUG

## If true, this property is "deserialized into", meaning the property's existing value
## is passed to [method JSONSerializer._deserialize_into]. If false, a new value is constructed
## from the JSONSerializer via [method JSONSerializer._deserialize]. Only supported for specific
## types, such as [Object], [Array], and [Dictionary] (as of now), if the type is not
## supported or the existing value is null, this property is ignored & deserialize is used.
## [br]NOTE: For [Array]s & [Dictionary]s, if true the deserialized elements are appended to the
## existing array/dictionary. It is [b]HIGHLY[/b] recommended to set this to true for typed arrays,
## as the inner system to construct typed arrays will break if the array's type changes.
@export var deserialize_into: bool = false

## For use only in the editor
var _editor_script: Script:
	set(value):
		_editor_script = value
		notify_property_list_changed()
	get():
		if _editor_script != null:
			return _editor_script
		if _editor_class_name.is_empty() || ClassDB.class_exists(_editor_class_name):
			return null
		var script_path: String = GodotJSONUtil.get_script_path_from_class_name(_editor_class_name)
		if script_path.is_empty():
			return null
		if FileAccess.file_exists(script_path):
			return load(script_path) as Script
		return null

## For use only in the editor
var _editor_class_name: StringName:
	set(value):
		_editor_class_name = value
		notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if !Engine.is_editor_hint():
		return
	
	# Add all properties in the class as editor suggestions
	if property.name == "property_name":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		
		var hints: PackedStringArray = PackedStringArray()
		var base_type: String = _editor_class_name
		
		# Handle custom class
		var script: Script = _editor_script
		if script != null:
			for script_property: Dictionary in script.get_script_property_list():
				# Ignore TYPE_NIL properties (not real properties) and non-serializable ones
				if script_property.type != TYPE_NIL \
				and JSONSerialization.is_type_serializable(script_property.type):
					hints.append(script_property.name)
			base_type = script.get_instance_base_type()
		
		# Handle native/base class
		if ClassDB.class_exists(base_type):
			# Handle native classes
			for class_property: Dictionary in ClassDB.class_get_property_list(base_type, false):
				# Ignore TYPE_NIL properties (not real properties) and non-serializable ones
				if class_property.type != TYPE_NIL \
				and JSONSerialization.is_type_serializable(class_property.type):
					hints.append(class_property.name)
		
		property.hint_string = ",".join(hints)
	
	# This code hides the "deserialize_into" if 
	if property.name == "deserialize_into":
		for class_property: Dictionary in _editor_get_class_properties():
			if property_name == class_property.name:
				if !JSONSerialization.can_deserialize_into_type(class_property.type):
					property.usage = PROPERTY_USAGE_NONE
				break


## Editor tool method to get the property list from the class this config
func _editor_get_class_properties() -> Array[Dictionary]:
	assert(Engine.is_editor_hint(), "editor_get_class_properties() for Editor use only")
	var properties: Array[Dictionary] = []
	if _editor_script != null: # Script is set, resolve properties from that
		properties.append_array(_editor_script.get_script_property_list())
		properties.append_array(ClassDB.class_get_property_list(_editor_script.get_instance_base_type()))
	else: # Script not set, try to resolve script
		var script_path: String = GodotJSONUtil.get_script_path_from_class_name(_editor_class_name)
		if !script_path.is_empty():
			var script: Script = load(script_path) as Script
			if script != null: # Script exists, get properties from it
				properties.append_array(script.get_script_property_list())
				properties.append_array(ClassDB.class_get_property_list(script.get_instance_base_type()))
		elif ClassDB.class_exists(_editor_class_name): # Script doesn't exist, check if type is native
			properties.append_array(ClassDB.class_get_property_list(_editor_class_name))
	
	return properties

func _to_string() -> String:
	return "JSONProperty(json_key=%s,property_name=%s)" % [json_key, property_name]
