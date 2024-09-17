class_name ObjectExample extends Node


func _ready() -> void:
	# Since this example doesn't have JSONObjectConfigRegistry.tres file I'll manually add these
	# to the default registry of JSONSerialization.
	JSONSerialization.object_config_registry.add_config(load("res://examples/object/config_game_player.tres"))
	JSONSerialization.object_config_registry.add_config(load("res://examples/object/config_game_item.tres"))
	JSONSerialization.object_config_registry.add_config(load("res://examples/object/config_game_item_chest.tres"))
	
	
	# We'll construct some bogus player & item data, this would come from your own game
	# but this isn't a game so we don't have data :(
	
	# Creating the player
	var my_player: GamePlayer = preload("./game_player.tscn").instantiate()
	my_player.player_name = "neth"
	my_player.player_color = Color.LIME
	my_player.position = Vector2(100.0, 200.0)
	
	# Let's make some items
	var pickaxe: GameItem = GameItem.new()
	pickaxe.name = "pickaxe"
	pickaxe.durability = 25.0
	pickaxe.level = 10
	var shovel: GameItem = GameItem.new()
	shovel.name = "shovel"
	shovel.durability = 1.0
	shovel.level = 1
	var sword: GameItem = GameItem.new()
	sword.name = "sword"
	sword.durability = 1_000.0
	sword.level = 100
	
	# Give them to the player
	my_player.items.append_array([pickaxe, shovel, sword])
	
	# Let's give the player a couple of valuables
	var diamond: GameItem = GameItem.new()
	diamond.name = "diamond"
	var emerald: GameItem = GameItem.new()
	emerald.name = "emerald"
	
	# Those should be in a chest
	var chest: GameItemChest = GameItemChest.new()
	chest.name = "neth's chest"
	chest.durability = 100.0
	chest.contents.append_array([diamond, emerald])
	
	# We could even put chests w/ contents in other chests. And so on. I won't 
	# because I respect the rules of Minecraft, but you get the idea.
	
	# The player has the chest
	my_player.items.append(chest)
	
	# We'll save the player string here to compare to the loaded object next.
	# This only works because I override _to_string() in those objects.
	var old_player_string: String = my_player.to_string()
	
	# Now the player is setup. It's the only object we need to serialize since
	# all of the items are stored in it.
	
	# Serialization time, it's this easy.
	var json: String = JSONSerialization.stringify(my_player)
	
	# Printing it out in case you want to see what it looks like, I recommend
	# pasting it into a JSON beauitifier.
	print(json)
	
	# Roleplay Time: You now store the JSON. The player quits. Later they want 
	# to play again so it's time to load. (You now load the json text from the 
	# file and set it to the json var)
	#
	# Save example:
	# var file_access: FileAccess = FileAccess.open("user://save.json", FileAccess.WRITE)
	# file_access.store_string(json)
	# file_access.close()
	#
	# Load example:
	# json = FileAccess.get_file_as_string("user://save.json")
	
	
	# We parse the JSON and set the player instance to what was returned, which
	# is a NEW instance of a GamePlayer. But has the same data.
	# Note the cast "as GamePlayer"; parse(json) returns a Variant so
	# for the editor to respect that this is a GamePlayer we have to cast.
	my_player = JSONSerialization.parse(json) as GamePlayer
	
	# We can run a quick check to see if it matches up (which it will)
	if my_player.to_string() == old_player_string:
		print("\nLoading worked, check out our new player below: \n")
		print(my_player)
	else:
		print("It did not work :(")
