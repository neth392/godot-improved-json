# Godot Improved JSON

## NOTE: This branch is incomplete & will eventually become its own project (if I ever get to completing it)

![Godot-JSON Icon](icon.png)

Godot Improved JSON is a Godot 4.3 or later addon that provides seamless methods of serializing & deserializing any variant, including Objects and their properties.
<br>  

## Table of Contents
- [Features](#Features)
- [FAQ](#FAQ)
- [Why?](#Why)
- [Support Links](#Support-Links)
- [Installation](#Installation)
- [Limitations and Important Notes](#Limitations-and-Important-Notes)
- [Basic Usage](#Basic-Usage)
- [Object Serialization](#Object-Serialization)
- [Resource File Instances](#Resource-File-Instances)
- [Examples](./examples/)
	- [Custom Objects](examples/object)
<br>  

## Features
- Provides a `JSONSerialization` autoloaded/globally accessible class with several functions for converting any type to/from JSON.
- All `Variant.Type`s are supported. 
	- No longer will your `StringName` be deserialized as a `String`, or your `int` as a `float`. Types are deserialized as the *exact* type they were when serialized.
- Custom & Native object support (including resources, nodes, anything that extends `Object`).
	- Configurations for each class define what is to be serialized, only including the properties that you define thus compacting JSON making for smaller files and quicker load & save times.
	- Assign an `id` to each class's config, and a `json_key` to each property. This allows you to change class names, script paths, & property names without having to modify the old JSON. Simply update the JSON config for the class that changed.
	- Automatically instantiate a `PackedScene` from JSON for `Node` derived classes; keep your default values default!
- Editor tools for quickly creating JSON object configurations
	- Simply dragging & dropping a script or PackedScene will auto populate most of the fields needed to create a JSON object configuration.
	- When selecting properties to be serialized, the addon automatically detects what properties your class has and suggests them via a drop down so you don't have to worry about typos.
- Ability to store "references" to local `*.tres` Resource files within JSON, and upon deserialization load an instance from the resource file. (see [Resource File Instances](#Resource-File-Instances) for a better explanation)
- WeakRef support, works well with the above resource file instance system.

<br>  

## FAQ
- **Does it work with versions earlier than 4.3?**  No, it relies on `Script.get_global_name()` which is a feature only added in 4.3.
<br>  

## Why?
Originally this project was created to bring JSON support to all of Godot's native types, including Objects & their properties. But with [Godot 4.4-dev2](https://godotengine.org/article/dev-snapshot-godot-4-4-dev-2/)'s release, [this pull request](https://github.com/godotengine/godot/pull/92656) was merged doing just that. However, after testing the new changes there were still issues that this project solves, the main one being that custom Objects are not supported.

The current issues with Godot's new JSON changes that this project addresses are:
- `JSON.stringify(variant)` and `JSON.parse(variant)` do not detect the variant's type, it is redundantly required to use `JSON.stringify(JSON.from_native(variant))` and `JSON.to_native(JSON.parse(variant))`. Improved JSON automatically detects any variant's type and serializes it accordingly, without the need for boilerplate.
- JSON Object support for custom objects in native Godot doesn't act as you'd expect. In the above point, if `variant` were to be an instance of `MyCustomClass`, when you deserialize it you will not receive an instance of `MyCustomClass`, just an instance of its base type (such as Resource). Attempting to include the script will actually include the *entire source code*, a massive security issue. So there is no property way to simply convert your objects to JSON & back without your own boilerplate, which this project aims to eliminate.
- A lot of internal properties that you don't need serialized are included Godot's `JSON.to_native` function. With this project, you tell the system what should be serialized. This tremendously cuts down the file sizes and speeds up load times. But most importantly it ensures your saving & loading behave how *you* want it to.
- Godot 4.4's new `JSON.from_native()` method returns a Dictionary that contains fully spelled out keys such as `__gdtype` for the `Variant.Type`, `basis` and `origin` for `Transform3D`'s values, & more. Improved Godot JSON uses short, one character keys. Again, this increases efficiency and reduces file size, which can add up when dealing with larger JSON files.

<br>  

## Support Links
For now, [open up a new issue](https://github.com/neth392/godot-improved-json/issues) or message me on Discord for direct support @ **cneth**

<br>  

## Installation
\
Simple install from the [AssetLib](https://godotengine.org/asset-library/asset/3343), search for "Godot Improved JSON" in the editor's AssetLib tab  and click Download. Enable the plugin in Project Settings and then **reload the project**.

### Install from GitHub Releases:
1) [Download the latest release](https://github.com/neth392/godot-improved-json/releases)
2) With your project open in Godot, go to the "**AssetLib**" tab, press the "**Import...**" button, then navigate to the downloaded zip file and select & open it.
3) Click "**Install**" in the window that pops up. Click **OK**. 
4) Go to **Project Settings**, **Plugins**, and then enable `Improved Godot JSON`
5) Ignore any errors that appear and **reload the project.**


After installing it there is an additional step if you want `Object` support. In Project Settings there is a new setting the plugin adds under `improved_json/config/json_object_config_registry`. That setting must point to a resource of the type `JSONObjectConfigRegistry` anywhere within your project's directory (more on this later). So to set that up, right click the desired folder in the FileSystem dock and create a new `JSONObjectConfigRegistry` resource. The name or location don't matter, just make sure the extension is `.tres`. Go back to Project Settings and set the above setting to the file path of your new registry resource file.

<br>  
 
## Limitations and Important Notes
- Serialized objects **must** have an explicit `class_name` defined in their script.
- If a custom object has a constructor, it **must have default values for each parameter** unless you use `JSONSerialization.parse_into(object)` (which does not construct a new instance of an object). If a constructor does not have default parameters, an error explaining such will be thrown when you try to deserialize an instance of it.
- Only the first (top most) constructor  in a class's script is used. I am considering adding support for selecting which constructor, but as of now I believe it is best to just use the first constructor.
- Nested/inner classes are **not supported**.
- A `JSONObjectConfigRegistry` file somewhere in the project directory is **required**. Object serialization will not work without it, but the addon *shouldn't* break completely.
- `TYPE_CALLABLE`, `TYPE_SIGNAL`, `TYPE_RID`, & `TYPE_MAX`  are **not supported**.
- There is currently a "bug" that causes the `JSONSerialization` autoload to have it's `_ready()` function called twice in the editor when the project is opened. I have tried everything to fix this and can not figure it out (if anyone could help that would be amazing). This shouldn't be noticeable at all.
- For `Dictionary` & `Array` properties of an `Object`, their assigned types (i.e. Array\[ThisType]) are serialized & used for construction of new arrays/dicts. That means if you change the assigned type on the object's property it could break the saved data. If the assigned type(s) of a dictionary or array may change, utilize the `deserialize_into` of [JSONProperty Advanced](#JSONProperty-Advanced)

<br>  

## Basic Usage

The heart of Improved JSON lives within `JSONSerializationImpl` which is a class containing the core functionality. That is accessible via the autoload `JSONSerialization` the plugin adds to your project. This section does not include `Object`, or any `Array` / `Dictionary` containing any Objects. See [Object Serialization](#Object-Serialization) which explains the extra setup needed for objects.


### Serializing Variants
#### `JSONSerialization.stringify(variant)`
This method is the most direct & simple way to convert *any* variant directly to JSON. Internally, it translates the variant into a `Dictionary` parsable by Godot's native `JSON`, and then passes the dictionary to an internal `JSON` instance's `stringify(variant)` method, returning the JSON text as a result.

For those interested in how it works, that dictionary contains a `t` key whose value is the `Variant.Type` of the `variant` parameter, and a `v` key whose value represents the `variant` itself.

### Deserializing JSON
#### `JSONSerialization.parse(string)`
Any JSON string generated by `JSONSerialization.stringify(...)` can be deserialized with `parse(string)`. The returned variant will be a **NEW instance** of whatever was originally serialized. This means that any `Array` & `Dictionary` will not `==` the original instance due to how Godot compares those types, but their contents will be the exact same.

#### `JSONSerialization.parse_into(instance, string)`
This method has the same behavior as `parse(string)`, but instead of creating a new instance it will attempt to deserialize **into** the `instance` passed as the parameter. This is only supported by `Object`, `Array`, and `Dictionary`. It will throw an error if the passed `instance`'s type is not one of those just listed.

It is usually recommended to use this for `Dictionary` & `Array` types as internally Improved JSON stores the assigned type of those (ex: Array\[ThisType]) in the JSON, so changing that assigned type could break saved data. Most commonly this situation occurs when using Objects with JSON, and those objects have dictionary/array properties which are typed. In those cases you would use the `deserialize_into` of [JSONProperty Advanced](#JSONProperty-Advanced) to ensure that this method (`parse_into`) is called for that property instead of `parse`. 

### Creating a new instance of JSONSerialization
For the below two sections, you may want to create a new `JSONSerialization` instance instead of just always using the autoloaded/global one. Usually this isn't needed, but in the case it is you can do so by calling `JSONSerialization.new_impl()`. It will return a new `JSONSerializationImpl` which is the class that contains all of the functionality. It does extend `Node` (to support the autoload) but you should **not** add it to the scene tree. Remember to `queue_free()` it after you're done with it!

Creating a new instance will essentially "snapshot" the global instance at that current time, so any changes to the global instance will not reflect in the new instance and vice versa.

**REMINDER:** Since `JSONSerializationImpl` extends `Node`, you **must** `queue_free()` it when you are done with it. Otherwise it will remain in memory as an orphaned node.

### Configuring JSON.parse & JSON.stringify optional parameters
Godot's own `JSON` has a few optional parameters when calling `JSON.parse()` and `JSON.stringify()`. Those parameters are configurable via a few properties on the `JSONSerialization` instance; `indent`, `sort_keys`, `full_precision`, and `keep_text`. They all default to what they do in native Godot except `sort_keys` which has been set to `false` to preserve `Dictionary` ordering when deserializing.

### Accessing JSON errors
The internal `JSON` instance can be accessed via `JSONSerialization.get_json()`. You can read errors from it via the same methods, [`get_error_line()`](https://docs.godotengine.org/en/stable/classes/class_json.html#class-json-method-get-error-line) and [`get_error_message()`](https://docs.godotengine.org/en/stable/classes/class_json.html#class-json-method-get-error-message).

### Important Notes on Dictionaries
JSON does not allow for keys to be JSON objects or arrays, therefore *every* key in Godot's `Dictionary` type is stored as a String. 

The keys in a Dictionary's JSON equivalent are prefixed with the # index & a `:`, such as `0:`, `1:`, `2:`, and so on. This is because Objects, Arrays, & Dictionaries may have the same properties, keys, or values but are of different instances and are not truly equal `==`. Those identical variants are serialized to the exact same JSON, and JSON objects can not have the same key twice. So to support those rare cases, a prefix was added.

In order to preserve dictionary ordering ([it does exist in Godot](https://docs.godotengine.org/en/stable/classes/class_dictionary.html#description)), `JSONSerializationImpl.sort_keys` **must** be `false`. Otherwise, Godot's `JSON` class will not preserve your key ordering when serializing.

<br>  

## Object Serialization
Below explains the setup to allow Objects to be serialized by `JSONSerialization`'s methods. It is a codeless solution that you should only have to do once and just maintain over the course of your project's development cycle. 

### `JSONObjectConfigRegistry`
In [installation](#Installation) we went over creating this resource file & setting it in project settings. Now to explain the use of it. This resource is where you register your `JSONObjectConfig` resources so that `JSONSerialization` can properly serialize & deserialize objects of different classes. You add them to the `user_conifgs` export and that's it.

### `JSONObjectConfig`
Each `JSONObjectConfig` represents a specific class that can be serialized/deserialized. It is the specification or template on how to do such with an object of that class. Ideally these should be saved as their own individual files and then registered to the `JSONObjectConfigRegistry`. 

The purpose behind this is to only include properties that need to be serialized, no extra BS. It was designed to support the refactoring of scripts & scenes, and the changing of class names & property names. Each of the exported properties will be explained below.

### `id`
The ID is stored in JSON text when an object of this type is serialized. Every `id` must be completely **unique** from every other config's id. **This should be set and not changed**, if it is changed it will break saved data. I usually set this as the `class_name` of the object, and infact if you set one of the below 2 properties first `id` will automatically set to the class name. The only downside is if the class name changes, the ID can't and will still be the old class name.

It *is* safe to change the `id` if you're game is still in development and you aren't worried about breaking saves. But once you publish and users have saved content, **DO. NOT. CHANGE. THIS.** If you do, I send my prayers <3

### `for_class` & `set_for_class_by_script`
These two properties are directly linked. They represent the class the config is for.

If it is for a custom class, you can simply drag the `GDScript` from the FileSystem dock to the `set_for_class_by_script` property. You'll notice the `for_class` automatically updates & locks as it is now derived from the script. This is the recommended method for any custom classes.

For native classes, such as Label, Button, etc. you can click the `for_class` value and search for the class and simply click on it.

**NOTE:** If a class name changes & you did NOT set it by the script, you must update it manually. But if you set it by the script, any changes to the class name or script path will automatically update.

### `instantiator`
This must be set to one of the `JSONInstantiator` implementations. It allows you specify how to create instances of the object.

### For PackedScenes
If your class is part of a `PackedScene`, set it to a `JSONSceneInstantiator`. Set that instantiator's `scene` property by dragging your `tscn` file from the FileSystem dock. Your `PackedScene` must be able to be instantiated via `PackedScene.instantiate()` which is what is called internally.

### For Non-Scene Custom Classes
For anything such as extends Object, Resource, RefCounted, etc. you can use the `JSONScriptInstantiator`. This time drag your `.gd` script to the `gd_script` property of the instantiator. Instances of these objects will be created via `new(...)`. Only the **first constructor** defined will be used. All parameters **must have default values** or an error will be thrown. No constructor is required though.

### For Native Classes
To create instances of native godot classes (nodes, resources, etc) use a `JSONNativeObjectInstantiator`. Simply set the `_class` property by clicking on the value and selecting the class this config is for. Instances are internally created via `ClassDB.instantiate(...)`. 

### `properties` & `JSONProperty`
This is below `extend_other_config` in the editor inspector but it is important to understand properties first.

This is an array of `JSONProperty` resources. A `JSONProperty` represents a property in an object that is to be serialized & deserialized. For each property of an object you want to serialize, you need to create a `JSONProperty` to represent it. These resources should usually not be saved to their own files. Just create & store them in the `JSONObjectConfig`.

### `JSONProperty.json_key`
This is just like `id` of `JSONObjectConfig`. It is serialized & stored in JSON to identify the property. I usually set it to the property name, and you'll notice if you set `property_name` it'll automatically populate to that if not set yet.

**NOTE: IT CAN NOT CHANGE** or it will break existing save data. Not going to give another lecture but just remember this. It must be unique from the other keys of all other `JSONProperty`s of this object, doesn't need to be unique across the project. It helps preserve against property name changes as it allows `property_name` (explained below) to change without breaking saved data.

### `JSONProperty.property_name`
This is simply the actual property name within the object. You **do** need to change this is if the property name changes. The editor inspector will display a dropdown of all available properties for your convenience. If it doesn't show up your `for_class` or `set_for_class_by_script` isn't set correctly.

### JSONProperty Advanced
**`enabled`**

Disable or enable this property.

**`allow_null`**

If false, throws an error (only in debug mode) if the property's value is null at time of serialization.

**`deserialize_into`**
This option only appears if the property's type is an `Object`, `Array`, or `Dictionary` and thus supports "deserializing into", meaning that a new variant is not created but instead the default value of the property is used & only it's contents (elements for `Array`, keys/values for `Dictionary`, property values for `Object`) are populated. 

It is **highly recommended** to set this to true for `Array` or `Dictionary` properties since internally Improved JSON stores the type of value (i.e. Array\[ThisType]) in the JSON so changing that type and not using `deserialize_into` could break saved data as the newly constructed `Array`/`Dictionary` may not have the same types as the property, causing the value to not be set to the property. Just do keep in mind that any data added to the array/dictionary will not be cleared when deserializing into.

**`if_missing_in_object_serialize`**

How to handle `property_name` not being present in an object when an attempt is made to serialize it. Usually should be `ERROR_DEBUG` as it represents a bad configuration.

**`if_missing_in_json`**

How to handle `json_key` not being present in JSON that represents this object. Usually should be `IGNORE` as you may add properties which are not in older saves.

**`if_missing_in_object_serialize`**

How to handle `property_name` not being present in an object when an attempt is made to deserialize an instance of it from JSON. Usually should be `ERROR_DEBUG` as it represents a bad configuration.

### `JSONObjectConfig.extend_other_config`
This property allows you to drag over another `JSONObjectConfig` resource from the FileSystem dock as the value. Say you have `ParentClass` and then `ChildClass extends ParentClass`. You have a `JSONObjectConfig` for each of them. Both classes have some of their own properties but you don't want to waste time creating a `JSONProperty` for each of `ParentClass`'s properties *again* on `ChildClass`'s config. You can then set the child config's `extend_other_config` to the config of the parent by dragging the parent config to it from the FileSystem dock. The child's config will now inherit all `JSONProperty`s defined in the parent config.

You can still override those parent properties within the child config by just creating new `JSONProperty`s in the child config and setting the `property_name` to the same value. `json_key` does not have to be the same. You can also disable specific parent properties by doing that and setting `enabled` to false.
<br>  

### Example:
For an example of a few custom objects & a breakdown on how I set them up, see the [Object Example](examples/object).
<br>  

### All Done!
You're now able to serialize & deserialize your own custom objects. Just remember to register them to the `JSONObjectConfigRegistry` resource defined in your project.

<br>  

## Resource File Instances
Within your project you're probably utilizing Godot's resource system, saving instances of resources to `.tres` files and then loading them. There is a configurable system in place within `JSONObjectConfig` that can load that exact instance of the `.tres` file instead of creating a new instance of the resource's class. This feature uses `CACHE_MODE_REUSE` so that when loaded from JSON they will directly `==` the same instance of that `.tres` you have loaded previously elsewhere in the project, or even `==` other instances of the same resource file that appear multiple times in the JSON.

For these properties to appear in the editor inspector while modifying a `JSONObjectConfig`, the `for_class` or `set_for_class_by_script` must have `Resource` as an ancestor.

**NOTE:** This feature will not be used if `deserialize_into` is set to true for any `JSONProperty` of a class that this is configured for. Nor will it be used if `JSONSerialization.parse_into` is used. It will only work when dealing with constructing new resource instances from JSON.

Example use case:

- You have a resource file `sword_item.tres` whose script is `item.gd` & class is `class_name Item extends Resource`
- You want to serialize your `Player` node, who has a property of `items: Array[Item]`
- Before this change, a new `Item` instance would be created during deserialization. Same property values as `sword_item.tres` but it would NOT equal (`==`) `load("sword_item.tres")`. Therefore, `items.has(sword_item)` would return false. 
- Now, with the proper configuration (see below), you can load `sword_item.tres` to `var sword_item`, and after deserializing the `Player` into `var player`, `player.items.has(sword_item)` will return true as the exact resource instance was loaded by Improved JSON from `sword_item.tres` via `CACHE_MODE_REUSE`.

### `maintain_resource_instances`
This property enables or disables the "resource file instance" system. When enabled the below properties will appear in the editor.

### `use_resource_path`
If `true` this will store the `Resource.resource_path` in the JSON so that when it is deserialized, the instance is loaded from this path. It isn't recommended as resource paths change, and that will break the JSON. 

### `include_properties_in_file_instances`
If `true`, for every `Resource` instance with a `resource_path` (thus meeting the "maintain resource instances" criteria) all `JSONProperty` instances in `JSONObjectConfig.properties` will be included in the serialized JSON, and also included when deserializing. This means that properties will be read from that resource instance, stored to JSON, and then set to the resource instance which is directly linked to the `.tres` file. For that reason, this is usually recommended to leave this as `false` since the point of this system is to use references of `.tres` files from `res://`, and almost always those `.tres` files shouldn't be changed by the game, but only by you the developer.  

### `resource_file_instances`
Only applicable if `use_resource_path` is `false`. This is an array of `JSONResourceFileInstance`s, another resource added by this plugin. Each `JSONResourceFileInstance` represents a specific `.tres` file whose class is `JSONObjectConfig.for_class`. It allows for fine tuning of each resource, and preserves against resource file path/name changes due to its `id` property. It also allows enabling/disabling `JSONProperty` on a per-resource basis. The only downside is *every* `.tres` file you want to maintain an instance of will need to be added here.

### `JSONResourceFileInstance`

#### `id`
This is exactly like `JSONObjectConfig.id`, and `JSONProperty.json_key`. It is stored in the JSON instead of the `.tres` path so that the path can change without breaking saved data.

#### `resource`
This is the actual `.tres` file. You should drag it from the inspector. When set, it'll auto-populate the `id` (if it is empty) with the file name for your convenience. It'll also set the `path_to_resource`.

#### `path_to_resource`
An alternative to `resource`, this can be set as well. Should support sub-resources if you have their exact path, but haven't tested.

#### `include_properties`
The same as `JSONObjectConfig.include_properties_in_file_instances`, but only applies to the `resource` set above. 
<br>  


[Back to Top ↑](#Godot-Improved-JSON)
