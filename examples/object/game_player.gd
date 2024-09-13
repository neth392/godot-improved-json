## Represents a player in the game.
class_name GamePlayer extends Node2D

var player_name: StringName
var player_color: Color
var items: Array[GameItem]


## This will help us make sure everything worked over in object_example.gd
func _to_string() -> String:
	return "GamePlayer(player_name=%s,player_color=%s,position=%s,items=%s)" \
	% [player_name, player_color, position, items]
