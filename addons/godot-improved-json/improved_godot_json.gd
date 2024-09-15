@tool
extends EditorPlugin

var icon: Texture2D = preload("res://icon.png")

func _get_plugin_name() -> String:
	return "Improved Godot JSON"


func _get_plugin_icon() -> Texture2D:
	return icon


func _enable_plugin() -> void:
	add_autoload_singleton("JSONSerialization", "serialize/json_serialization.tscn")


func _disable_plugin() -> void:
	remove_autoload_singleton("JSONSerialization")
