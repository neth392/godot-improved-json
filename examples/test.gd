extends Control

@onready var label: Label = $Label

func _ready() -> void:
	label.text = "korvo"
	
	var saved: String = JSONSerialization.stringify(label.text)
	print(saved)
	
	var loaded: String = saved
	var player_name: String = JSONSerialization.parse(loaded)
	label.text = player_name
