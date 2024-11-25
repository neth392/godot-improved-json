## Autoloaded class (named JSONSerialization) responsible for managing [Serializer]s and providing
## serialization & deserialization. See [SerializationImpl] (the implementation) for more information.
@tool
class_name SerializationSingleton extends SerializationImpl

const _DEFAULT_REGISTRY_PATH: String = "res://object_config_registry.tres"

const _SETTING_PATH: String = "improved_serialization/config/object_config_registry"

var _registry_path: String:
	get():
		return ProjectSettings.get_setting(_SETTING_PATH, _DEFAULT_REGISTRY_PATH)
	set(value):
		assert(false, "_registry_path is read only")

# Keep a record of the registry path to detect if it changes
var _registry_path_cache: String
var _ignore_setting_change: bool = false

## If the Godot version is 4.4 or later.
var _is_4_4_or_later: bool = false

## Constructs a new [SerializationImpl] instance with support for reading errors.
## The returned node should NOT be added to the tree.
func new_impl() -> SerializationImpl:
	var instance: SerializationImpl = SerializationImpl.new()
	instance.indent = indent
	instance.sort_keys = sort_keys
	instance.full_precision = full_precision
	instance.keep_text = keep_text
	instance._serializers = _serializers.duplicate(false)
	instance.object_config_registry = object_config_registry.copy()
	instance._color = _color
	instance._vector2 = _vector2
	instance._vector2i = _vector2i
	instance._vector3 = _vector3
	instance._vector4 = _vector4
	instance._basis = _basis
	return instance

func _ready() -> void:
	var version: Dictionary = Engine.get_version_info()
	_is_4_4_or_later = version.major >= 4 && version.minor >= 4
	
	# Add types confirmed to be working with PrimitiveSerializer
	# see default/primitive_json_serializer_tests.gd for code used to test this
	# Some were omitted as they made no sense; such as Basis which worked but
	# Vector3 didnt, and a Basis is comprised of 3 Vector3s ??? Don't want to risk that
	# getting all fucky wucky in a release build.
	add_serializer(PrimitiveSerializer.new(TYPE_NIL))
	add_serializer(PrimitiveSerializer.new(TYPE_BOOL))
	add_serializer(PrimitiveSerializer.new(TYPE_INT))
	add_serializer(PrimitiveSerializer.new(TYPE_FLOAT))
	add_serializer(PrimitiveSerializer.new(TYPE_STRING))
	add_serializer(PrimitiveSerializer.new(TYPE_STRING_NAME))
	add_serializer(PrimitiveSerializer.new(TYPE_NODE_PATH))
	add_serializer(PrimitiveSerializer.new(TYPE_PACKED_INT32_ARRAY))
	add_serializer(PrimitiveSerializer.new(TYPE_PACKED_INT64_ARRAY))
	add_serializer(PrimitiveSerializer.new(TYPE_PACKED_FLOAT32_ARRAY))
	add_serializer(PrimitiveSerializer.new(TYPE_PACKED_FLOAT64_ARRAY))
	add_serializer(PrimitiveSerializer.new(TYPE_PACKED_STRING_ARRAY))
	
	# TYPE_ARRAY
	add_serializer(preload("./native/array_json_serializer.gd").new())
	
	# TYPE_DICTIONARY
	if _is_4_4_or_later:
		# Conditionally load to prevent errors in the editor
		var gd_script: GDScript = GDScript.new()
		var path: String = get_script().resource_path.get_base_dir() + "/native/4_4_dictionary_json_serializer.txt"
		gd_script.source_code = FileAccess.get_file_as_string(path)
		gd_script.reload(false)
		add_serializer(gd_script.new())
	else:
		add_serializer(preload("./native/4_3_dictionary_json_serializer.gd").new())
	
	# TYPE_OBJECT
	add_serializer(preload("./object/object_json_serializer.gd").new())
	
	# TYPE_COLOR
	_color = preload("./native/color_json_serializer.gd").new()
	add_serializer(_color)
	
	# TYPE_PACKED_COLOR_ARRAY
	add_serializer(preload("./native/packed_color_array_json_serializer.gd").new())
	
	# TYPE_QUARTERNION
	add_serializer(preload("./native/quarternion_json_serializer.gd").new())
	
	# TYPE_VECTOR2
	_vector2 = preload("./native/vector2_json_serializer.gd").new()
	add_serializer(_vector2)
	
	# TYPE_PACKED_VECTOR2_ARRAY
	add_serializer(preload("./native/packed_vector2_array_json_serializer.gd").new())
	
	# TYPE_RECT2
	add_serializer(preload("./native/rect2_json_serializer.gd").new())
	
	# TYPE_TRANSFORM2D
	add_serializer(preload("./native/transform2d_json_serializer.gd").new())
	
	# TYPE_VECTOR2i
	_vector2i = preload("./native/vector2i_json_serializer.gd").new()
	add_serializer(_vector2i)
	
	# TYPE_RECT2i
	add_serializer(preload("./native/rect2i_json_serializer.gd").new())
	
	# TYPE_VECTOR3i
	add_serializer(preload("./native/vector3i_json_serializer.gd").new())
	
	# TYPE_VECTOR3
	_vector3 = preload("./native/vector3_json_serializer.gd").new()
	add_serializer(_vector3)
	
	# TYPE_PACKED_VECTOR3_ARRAY
	add_serializer(preload("./native/packed_vector3_array_json_serializer.gd").new())
	
	# TYPE_PLANE
	add_serializer(preload("./native/plane_json_serializer.gd").new())
	
	# TYPE_BASIS
	_basis = preload("./native/basis_json_serializer.gd").new()
	add_serializer(_basis)
	
	# TYPE_TRANSFORM3D
	add_serializer(preload("./native/transform3d_json_serializer.gd").new())
	
	# TYPE_AABB
	add_serializer(preload("./native/aabb_json_serializer.gd").new())
	
	# TYPE_VECTOR4i
	add_serializer(preload("./native/vector4i_json_serializer.gd").new())
	
	# TYPE_VECTOR4
	_vector4 = preload("./native/vector4_json_serializer.gd").new()
	add_serializer(_vector4)
	
	# TYPE_PACKED_VECTOR4_ARRAY
	add_serializer(preload("./native/packed_vector4_array_json_serializer.gd").new())
	
	# TYPE_PROJECTION
	add_serializer(preload("./native/projection_json_serializer.gd").new())
	
	# TYPE_PACKED_BYTE_ARRAY
	add_serializer(preload("./native/packed_byte_array_json_serializer.gd").new())
	
	# In editor; handle ProjectSettings for object config registry
	if Engine.is_editor_hint() && JSONSerialization == self:
		# Create the setting if it does not exist
		if !ProjectSettings.has_setting(_SETTING_PATH):
			ProjectSettings.set_setting(_SETTING_PATH, _DEFAULT_REGISTRY_PATH)
		
		# Set the initial values & info for it every time
		ProjectSettings.set_initial_value(_SETTING_PATH, _DEFAULT_REGISTRY_PATH)
		ProjectSettings.set_as_basic(_SETTING_PATH, true)
		ProjectSettings.add_property_info({
			"name": _SETTING_PATH,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tres"
		})
		# Cache the registry path to detect changes
		_registry_path_cache = _registry_path
		# Connect to changes
		ProjectSettings.settings_changed.connect(_on_project_settings_changed)
		
		# Load the editor tools script to get the FileSystemDock instance;
		# EditorInterface does not exist in exported projects.
		var editor_tools_path: String = get_script().resource_path.get_base_dir() + \
		"/json_serialization_editor_tools.gd"
		var editor_tools: Object = load(editor_tools_path).new()
		editor_tools.get_file_system_dock().files_moved.connect(_on_file_moved)
		editor_tools.get_file_system_dock().file_removed.connect(_on_file_removed)
	
	# Load the registry
	_reload_registry(!Engine.is_editor_hint())



# Handle object config registry path changing
func _on_project_settings_changed() -> void:
	if _ignore_setting_change:
		return
	# Check if there was a change, if not return
	if _registry_path == _registry_path_cache:
		return
	_registry_path_cache = _registry_path
	_reload_registry(true)


# Handle registry being moved in editor
func _on_file_moved(old_file: String, new_file: String) -> void:
	if old_file == _registry_path || new_file == _registry_path:
		_ignore_setting_change = true
		ProjectSettings.set_setting(_SETTING_PATH, new_file)
		_registry_path_cache = new_file
		_reload_registry(true)
		_ignore_setting_change = false


func _on_file_removed(file: String) -> void:
	if file == _registry_path:
		_reload_registry(true)


# Loads and sets the registry
func _reload_registry(verbose: bool) -> void:
	if JSONSerialization != self:
		return
	var registry: SerializationObjectConfigRegistry = null
	# File exists
	if FileAccess.file_exists(_registry_path):
		registry = ResourceLoader.load(_registry_path) as SerializationObjectConfigRegistry
		# Push warning if it couldn't be loaded
		if verbose && registry == null:
			push_warning(("SerializationObjectConfigRegistry @ path %s could not be loaded or " + \
			"is not of type SerializationObjectConfigRegistry") % _registry_path)
	elif verbose:
		# File doesn't exist, push warning
		push_warning(("No SerializationObjectConfigRegistry file found @ path %s.\nEnsure project " + \
		"setting %s points to a correct file.") \
		% [_registry_path, _SETTING_PATH])
	
	object_config_registry = registry
