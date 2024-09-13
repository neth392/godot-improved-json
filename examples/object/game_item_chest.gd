class_name GameItemChest extends GameItem

var contents: Array[GameItem]

## This will help us make sure everything worked over in object_example.gd
func _to_string() -> String:
	return "GameItemChest(name=%s,durability=%s,level=%s,contents=%s)" \
	% [name, durability, level, contents]
