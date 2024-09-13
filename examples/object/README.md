
# Object Example Walkthrough
This page will walk you through how the object example works & was made. This isn't a functional game, but should give you an idea how to implement this project in your own game. This example assumes you have already read over the [Basic Example](../basic/readme.md) and have your project's `ObjectJSONConfigRegistry` configured.

## Table of Contents
- [The Data Objects](#The-Data-Objects)
	- [GamePlayer](#GamePlayer)
	- [GameItem](#GameItem)
	- [GameItemChest](#GameItemChest)
- [Implementing JSON Serialization](#Implementing-JSON-Serialization)
	- [Creating JSONObjectConfigs](#Creating-JSONObjectConfigs)
		- [GamePlayer Config](#GamePlayer-Config)
		- [GameItem Config](#GameItem-Config)
		- [GameItemChest Config](#GameItemChest-Config)
	- [Registering JSONObjectConfigs](#Registering-JSONObjectConfigs)
- [Wrapping it all up](#Wrapping-it-all-up)



## The Data Objects
A few objects I've created for this example are used, see their explanations below. Think of them as objects in your existing game.

### GamePlayer
[game_player.gd](game_player.gd)<br>
[game_player.tscn](game_player.tscn)<br>
This class stores some common player information. It extends `Node2D` so we also have access to all of those properties.

### GameItem
[game_item.gd](game_item.gd)
This class is a `Resource` used to store information on an "item".

### GameItemChest
[chest_game_item.gd](chest_game_item.gd)
This extends `GameItem` (which is very important to remember for later) and adds a new property, `items` which is an array of `GameItem`s representing the chest's contents.


## Implementing JSON Serialization
Here's how I've made it so my objects & their properties can be serialized. Not going to include anything on saving the generated JSON String to a file & loading it, that's not within the scope of this project.


### Creating JSONObjectConfigs
The first step is to create `JSONObjectConfig` resources for each object you want to serialize. I recommend creating a seperate `.tres` file for each & storing them in a seperate folder in the project for all of the configs, it helps keep the project organized. Alternatively you can create sub resources in your `JSONObjectConfigRegistry` file, but that is less than ideal to work with.

To create a config file, right click in the FileSystem window of the Godot editor and hit +Create New, Resource, and then search for `JSONObjectConfig`. You can then create the file.
#### GamePlayer Config
We'll start with player, which I put in [config_game_player.tres](config_game_player.tres). First we'll handle the `Set for Class by Script` property, I simply dragged the [game_player.gd](game_player.gd) script from the FileSystem to that property. The `for_class` property will automatically update & prevent you from editing it since it's now derived from that script.

Notice that the `id` has automatically been set. The `id` is arbitrary but must be unique from other configs, so usually it's best to leave it as the class name. However, **this id can not change** or it will break existing save files.

Now to create a `JSONInstantiator` resource for the `instantiator` property. Since this class is attached to a `Node` of a `PackedScene`, we want the new instances to be instantiated from that PackedScene. In the inspector click on the `<empty>` and then select a new `JSONSceneInstantiator` which supports PackedScenes. Click on the newly created resource and  drag the [game_player.tscn](game_player.tscn) file to the `Scene` property.

We can ignore `Extend other Config` as we don't have any configuration for `Node2D` that would help us save time on creating the following properties.

#### GamePlayer Config's Properties
In [game_player.gd](game_player.gd) there are 3 properties, `player_name`, `player_color`, and `items`. We want all of those to be serialized, but for the sake of this example we also want to include `Node2D.position`, which this class inherits. So 4 total properties.

Starting with `player_name`, with [config_game_player.tres](config_game_player.tres) open in the inspector add a new element to the `properties` array. Make it a new `JSONProperty` and expand it. First set the `property_name` by selecting the `player_name` from the property list dropdown. Notice now that the `json_key` automatically populates. It's usually the best practice to make the `json_key` the same as the property name, but **do note** this key **can not change** or it'll break existing save data. So if the property name changes this can't. The text of the key is completely irrelevant, it is just used to associate this property with the data in the JSON. More can be done under Advanced, but for this example we won't bother with that. The property is now configured.

Repeat the same steps with `player_color` & `items` and now those are configured. One note on `items`; since it is an `Array` it can be *deserialized into*, which is an option under advanced. That means that the property's existing value is used and a new array instance isn't created, so you could add some default items there available for *every* new `GamePlayer` instance and they will remain when you deserialize into it. Up to you if you need that functionality or not, but for this example we don't.

For `position`, which is a member of the parent class `Node2D`, the same steps can be taken. Improved JSON automatically detects inherited properties in it's dropdown.

#### GameItem Config
Found in [config_game_item.tres](config_game_item.tres). Set the class by script again by dragging [game_item.gd](game_item.gd) to the `for_class` property. This time for the `instantiator` we'll use the `JSONScriptInstantiator` since this class is not associated with any `.tscn` file. Create a new instance of that and again just drag game_item.gd to the `gd_script` property of it.

We only want `GameItem`'s own properties serialized, `name`, `durability`, & `level`. The same steps are taken as were with GamePlayer's properties. This config is now complete.

#### GameItemChest Config
Found in [config_game_item_chest.tres](config_game_item_chest.tres). Using [game_item_chest.gd](game_item_chest.gd) take the same steps up to completing the instantiator.

Now is where we will utilized `extend_other_config`.  `GameItemChest extends GameItem` is why. We want any chest instance to also have its parent properties from `GameItem` to be serialized. So instead of wasting time redefining them, we can drag [config_game_item.tres](config_game_item.tres) to `extend_other_config` and now Improved JSON will also include properties from that config file.

For this class's properties we just want `contents`, added the same way as all of the others.


### Registering JSONObjectConfigs
The most important part is to remember to add these new config files to your JSONObjectConfigRegistry resource's `user_configs` array property, gone over in the [main README](../README.md). If you forget, it will not work. You *can* also do what I did in this example (as I don't have any registry file set for this project) and manually add them each time your game starts up via `JSONSerialization.object_config_registry.add_config(config)`, but that isn't recommended.


## Wrapping it all up
Check out the code & comments in [object_example.gd](object_example.gd) to see how this now ties into saving & loading. A lot easier to see the code in action with explanations than it is to read another wall of text here.