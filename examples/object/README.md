
# Object Example Walkthrough
This page will walk you through how the object example works. This isn't a functional game, but should give you an idea how to implement this project in your own game. This example assumes you have already read over the [Basic Example](../basic/readme.md) and have your project's `ObjectJSONConfigRegistry` configured.

## Table of Contents
- [The Data Objects](#The-Data-Objects)
	- [GamePlayer (game_player.gd & game_player.tscn)](#GamePlayer-(game_player.gd-&-game_player.tscn))
	- [GameItem (game_item.gd)](#GameItem-(game_item.gd))
	- [GameItemChest](#GameItemChest-(game_item_chest.gd))
- [Implementing JSON Serialization](#Implementing-JSON-Serialization)
	1. [1. Creating JSONObjectConfigs](#1.-Creating-JSONObjectConfigs)

## The Data Objects
A few objects I've created for this example are used, see their explanations below. Think of them as objects in your existing game.

### GamePlayer (game_player.gd & game_player.tscn)
This class stores some common player information. It extends `Node2D` so we also have access to all of those properties. It also has a `Sprite2D` as a child which I'll use as an example on how you can access child nodes in the serialization process.

### GameItem (game_item.gd)
This class is a `Resource` used to store information on an "item".

### GameItemChest (chest_game_item.gd)
This extends `GameItem` (which is very important to remember for later) and adds a new property, `items` which is an array of `GameItem`s representing the chest's contents.


## Implementing JSON Serialization
Here's how I've made it so my objects & their properties can be serialized. Not going to include anything on saving the generated JSON String to a file & loading it, that's not within the scope of this project.

### 1. Creating JSONObjectConfigs
The first step is to create `JSONObjectConfig` resources for each object you want to serialize. I recommend creating a seperate `.tres` file for each & storing them in a seperate folder in the project for all of the configs, it helps keep the project organized. Alternatively you can create sub resources in your `JSONObjectConfigRegistry` file, but that is less than ideal to work with.

To create a config file, right click in the FileSystem window of the Godot editor and hit +Create New, Resource, and then search for `JSONObjectConfig`. You can then create the file.
#### GamePlayer Config
We'll start with player, which I put in [config_game_player.tres](config_game_player.tres). First I gave it an `id`, I prefer using the `class_name`s of the objects, but remember that the ID **can not change** or it will break existing saves. 

Next, in the `Set for Class by Script` property, I simply dragged the [game_player.gd](game_player.gd) script from the FileSystem to that property. The `For Class` property will automatically update & prevent you from editing it since it's now derived from that script.

Now to create a `JSONInstantiator` resource for the `instantiator` property. Since this class is attached to a `Node` of a `PackedScene`, we want the new instances to be instantiated from that PackedScene. In the inspector click on the `<empty>` and then select a new `JSONSceneInstantiator` which supports PackedScenes. Click on the newly created resource and  drag the [game_player.tscn](game_player.tscn) file to the `Scene` property.

We can ignore `Extend other Config` as we don't have any configuration for `Node2D` that would help us save time on creating the following properties.

##### GamePlayer Config's Properties
In [game_player.gd](game_player.gd) there are 3 properties, `player_name`, `player_color`, and `items`. We want all of those to be serialized, but for the sake of this example we also want to include `Node2D.position`, which this class inherits. So 4 total properties.

Starting with `player_name`, with [config_game_player.tres](config_game_player.tres) open in the inspector add a new element to the `properties` array. Make it a new `JSONProperty` and expand it. First set the `property_name` by selecting the `player_name` from the property list dropdown. Notice now that the `json_key` automatically populates. It's usually the best practice to make the `json_key` the same as the property name, but **do note** this key **can not change** or it'll break existing save data. So if the property name changes this can't. The text of the key is completely irrelevant, it is just used to associate this property with the data in the JSON. More can be done under Advanced, but for this example we won't bother with that. The property is now configured.

Repeat the same steps with `player_color` & `items` and now those are configured. One note on `items`; since it is an `Array` it can be *deserialized into*, which is an option under advanced. That means that the property's existing value is used and a new array instance isn't created, so you could add some default items there available for *every* new `GamePlayer` instance and they will remain when you deserialize into it. Up to you if you need that functionality or not, but for this example we don't.

For `position`, which is a member of the parent class `Node2D`, the same steps can be taken. Improved JSON automatically detects inherited properties in it's dropdown.

#### GameItem Config
Set the class by script again by dragging ``