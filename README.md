# Godot Improved JSON

![Godot-JSON Icon](icon.svg)

Godot Improved JSON is a Godot 4.4 (or later) addon that provides seamless methods of serializing & deserializing any variant, including Objects and their properties.
<br>  

## Table of Contents
- [FAQ](#FAQ)
- [Why?](#Why)
- [Support Links](#Support-Links)
- [Installation](#Installation)
- [Limitations](#Limitations)
- [Basic Usage](#Basic-Usage)
- [Object Serialization](#Object-Serialization)
- [Examples](./examples/)
	- [Custom Objects](examples/object)
<br>  

## FAQ
- **Will versions earlier than Godot 4.4 be supported?** Yes, I am working on 4.3 support right now.
<br>  

## Why?
Originally this project was created to bring JSON support to all of Godot's native types, including Objects & their properties. But with [Godot 4.4-dev2](https://godotengine.org/article/dev-snapshot-godot-4-4-dev-2/)'s release, [this pull request](https://github.com/godotengine/godot/pull/92656) was merged doing just that. However, after testing the new changes there were still issues that this project solves, predominantly in regards to Objects.

The current issues with Godot's new JSON changes that this project addresses are:
- `JSON.stringify(variant)` and `JSON.parse(variant)` do not detect the variant's type, it is redundantly required to use `JSON.stringify(JSON.from_native(variant))` and `JSON.to_native(JSON.parse(variant))`. Improved JSON automatically detects any variant's type and serializes it accordingly, without the need for boilerplate.
- JSON Object support for custom objects in native Godot is still questionable, and currently appears broken. In the above point, if `variant` were to be an instance of `MyCustomClass`, when you deserialize it you will not receive an instance of `MyCustomClass`, just an instance of its base type (such as Resource). There is no property way to simply convert your objects to JSON & back without your own boilerplate, which this project aims to eliminate.
- A lot of internal properties that you don't need serialized are included Godot's `JSON.to_native` function. With this project, you tell the system what should be serialized. This tremendously cuts down the file sizes and speeds up load times. But most importantly it ensures your saving & loading behave how *you* want it to.
- Godot 4.4's new `JSON.from_native()` method returns a Dictionary that contains fully spelled out keys such as `__gdtype` for the `Variant.Type`, `basis` and `origin` for `Transform3D`'s values, & more. Improved Godot JSON uses short, one character keys. Again, this increases efficiency and reduces file size, which can add up when dealing with larger JSON files.

<br>  

## Support Links
For now, [open up a new issue](https://github.com/neth392/godot-improved-json/issues) or message me on Discord for direct support @ **cneth**

<br>  

## Installation
I'll be submitting this project to the Godot AssetLib for easier installation, & will update this accordingly once done. For now see the steps to install:
1) [Download the latest release](https://github.com/neth392/godot-improved-json/releases)
2) With your project open in Godot, go to the "**AssetLib**" tab, press the "**Import...**" button, then navigate to the downloaded zip file and select & open it.
3) Click "**Install**" in the window that pops up. Click **OK**. 
4) Go to **Project Settings**, **Plugins**, and then enable `Improved Godot JSON`
5) Ignore any errors that appear and **reload the project.**


After installing it there is an additional step if you want `Object` support. In Project Settings there is a new setting the plugin adds under `improved_json/config/json_object_config_registry`. That setting must point to a resource of the type `JSONObjectConfigRegistry` anywhere within your project's directory (more on this later). So to set that up, right click the desired folder in the FileSystem dock and create a new `JSONObjectConfigRegistry` resource. The name or location don't matter, just make sure the extension is `.tres`. Go back to Project Settings and set the above setting to the file path of your new registry resource file.

<br>  
 
## Limitations
- Serialized objects **must** have an explicit `class_name` defined in their script.
- If a custom object has a constructor, it **must have default values for each parameter** unless you use `JSONSerialization.parse_into(object)` (which does not construct a new instance of an object). If a constructor does not have default parameters, an error explaining such will be thrown when you try to deserialize an instance of it.
- Only the first (top most) constructor  in a class's script is used. I am considering adding support for selecting which constructor, but as of now I believe it is best to just use the first constructor.
- Nested/inner classes are **not supported**.
- A `JSONObjectConfigRegistry` file somewhere in the project directory is **required**. Object serialization will not work without it, but the addon *shouldn't* break completely.
- `TYPE_CALLABLE`, `TYPE_SIGNAL`, `TYPE_RID`, & `TYPE_MAX`  are **not supported**.
- There is currently a "bug" that causes the `JSONSerialization` autoload to have it's `_ready()` function called twice in the editor when the project is opened. I have tried everything to fix this and can not figure it out (if anyone could help that would be amazing). This shouldn't be noticeable at all.

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

The only real use here is to maintain original values in an Object, Array, or Dictionary, and append the values from the JSON.

### Creating a new instance of JSONSerialization
For the below two sections, you may want to create a new `JSONSerialization` instance instead of just always using the autoloaded/global one. Usually this isn't needed, but in the case it is you can do so by calling `JSONSerialization.new_impl()`. It will return a new `JSONSerializationImpl` which is the class that contains all of the functionality. It does extend `Node` (to support the autoload) but you should **not** add it to the scene tree. Remember to `queue_free()` it after you're done with it!

Creating a new instance will essentially "snapshop" the global instance at that current time, so any changes to the global instance will not reflect in the new instance and vice versa.

**REMINDER:** Since `JSONSerializationImpl` extends `Node`, you **must** `queue_free()` it when you are done with it. Otherwise there will be memory leaks.

### Configuring JSON.parse & JSON.stringify optional parameters
Godot's own `JSON` has a few optional parameters when calling `JSON.parse()` and `JSON.stringify()`. Those parameters are configurable via a few properties on the `JSONSerialization` instance; `indent`, `sort_keys`, `full_precision`, and `keep_text`. They all default to what they do in native Godot except `sort_keys` which has been set to `false` to preserve `Dictionary` ordering when deserializing.

### Accessing JSON errors
The internal `JSON` instance can be accessed via `JSONSerialization.get_json()`. You can read errors from it the same way you do via [`get_error_line()`](https://docs.godotengine.org/en/stable/classes/class_json.html#class-json-method-get-error-line) and [`get_error_message()`](https://docs.godotengine.org/en/stable/classes/class_json.html#class-json-method-get-error-message).

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

**`if_missing_in_object_serialize`**

How to handle `property_name` not being present in an object when an attempt is made to serialize it. Usually should be `ERROR_DEBUG` as it represents a bad configuration.

**`if_missing_in_json`**

How to handle `json_key` not being present in JSON that represents this object. Usually should be `IGNORE` as you may add properties which are not in older saves.

**`if_missing_in_object_serialize`**

How to handle `property_name` not being present in an object when an attempt is made to deserialize an instance of it from JSON. Usually should be `ERROR_DEBUG` as it represents a bad configuration.

### `JSONObjectConfig.extend_other_config`
This property allows you to drag over another `JSONObjectConfig` resource from the FileSystem dock as the value. Say you have `ParentClass` and then `ChildClass extends ParentClass`. You have a `JSONObjectConfig` for each of them. Both classes have some of their own properties but you don't want to waste time creating a `JSONProperty` for each of `ParentClass`'s properties *again* on `ChildClass`'s config. You can then set the child config's `extend_other_config` to the config of the parent by dragging the parent config to it from the FileSystem dock. The child's config will now inherit all `JSONProperty`s defined in the parent config.

You can still override those parent properties within the child config by just creating new `JSONProperty`s in the child config and setting the `property_name` to the same value. `json_key` does not have to be the same. You can also disable specific parent properties by doing that and setting `enabled` to false.

### All Done!
You're now able to serialize & deserialize your own custom objects. Just remember to register them to the `JSONObjectConfigRegistry` resource defined in your project.

### Example:
For an example of a few custom objects & a breakdown on how I set them up, see the [Object Example](examples/object).
<br>  


[Back to Top ↑](#Godot-Improved-JSON)