@tool
extends EditorPlugin

func _get_plugin_name() -> String:
	return "Improved Godot JSON"


func _enable_plugin() -> void:
	add_autoload_singleton("JSONSerialization", "serialize/json_serialization.tscn")


func _disable_plugin() -> void:
	remove_autoload_singleton("JSONSerialization")
