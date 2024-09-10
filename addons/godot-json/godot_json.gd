@tool
extends EditorPlugin

const _SETTING_PATH: String = "godot_json/config/enable_global_instance"
var _autoload_enabled: bool = false


func _get_plugin_name() -> String:
	return "godot-json"


func _enter_tree() -> void:
	# Set initial setting if not exist
	if !ProjectSettings.has_setting(_SETTING_PATH):
		ProjectSettings.set_setting(_SETTING_PATH, true)
		ProjectSettings.set_initial_value(_SETTING_PATH, true)
		ProjectSettings.set_as_basic(_SETTING_PATH, true)
	
	# Enable autoload if configured
	_autoload_enabled = ProjectSettings.get_setting(_SETTING_PATH, false)
	if _autoload_enabled:
		add_autoload_singleton("JSONSerialization", "serialize/json_serialization.tscn")
	
	# Monitor project setting changes to manage autoload
	ProjectSettings.settings_changed.connect(_on_project_settings_changed)


func _exit_tree() -> void:
	# Disconnect
	ProjectSettings.settings_changed.disconnect(_on_project_settings_changed)
	# Remove autoload if enabled
	if _autoload_enabled:
		remove_autoload_singleton("JSONSerialization")
		_autoload_enabled = false


func _on_project_settings_changed() -> void:
	var setting_value: bool = ProjectSettings.get_setting(_SETTING_PATH, false)
	if setting_value != _autoload_enabled:
		_autoload_enabled = setting_value
		if _autoload_enabled:
			add_autoload_singleton("JSONSerialization", "serialize/json_serialization.tscn")
		else:
			remove_autoload_singleton("JSONSerialization")
