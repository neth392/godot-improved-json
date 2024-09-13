class_name GameItem extends Resource

var name: String
var durability: float
var level: int

## This will help us make sure everything worked over in object_example.gd
func _to_string() -> String:
	return "GameItem(name=%s,durability=%s,level=%s)" % [name, durability, level]
