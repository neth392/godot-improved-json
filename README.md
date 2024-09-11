# Godot Improved JSON

![Godot-JSON Icon](icon.svg)

Godot Improved JSON is a Godot 4.4 (or later) addon that provides seamless methods of serializing any variant, including Objects and their properties.

## Why?
Originally this project was created to bring JSON support to all of Godot's native types, including Objects & their properties. But with [Godot 4.4-dev2](https://godotengine.org/article/dev-snapshot-godot-4-4-dev-2/)'s release, [this commit](https://github.com/godotengine/godot/pull/92656) was merged doing just that. However, after testing the new changes there were still issues that this project solves, predominantly in regards to Objects.

The current issues with Godot's new JSON changes that this project addresses are:
- `JSON.stringify(variant)` and `JSON.parse(variant)` do not detect the variant's type, it is redundantly required to use `JSON.stringify(JSON.from_native(variant))` and `JSON.to_native(JSON.parse(variant))`. Improved JSON automatically detects any variant's type and serializes it accordingly, without the need for boilerplate.
- JSON Object support in native Godot is still questionable, I'd even say broken/unsupported. In the above point, if `variant` were to be an instance of `MyCustomClass`, when you deserialize it you will not receive an instance of `MyCustomClass`, just an instance of its base type (such as Resource). There is no propery way to simply convert your objects to JSON & back without your own boilerplate, which this project aims to eliminate.

## Support Links
For now, message me on Discord for direct support: cneth

## Installation
TODO

## Limitations
#### Project in "Unsaved" State when opened
When opening the project with improved-godot-json enabled, the project will be in an "unsaved" state. This is due to the usage of [EditorPlugin.add_autoload_singleton()](https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-method-add-autoload-singleton)  to automatically register JSONSerialization as a global autoloaded scene, making it accessible throughout the project. There are no actual changes to the project's files, this is just a "bug" caused by 
##### Workaround
Uncheck the project setting `improved_json/config/enable_global_instance` and manually add `res://addons/godot-improved-json/serialize/json_serialization.tscn` to your Autoloads under the Globals tab in ProjectSettings. This will prevent the plugin from registering it every time the project is opened.

## Basic Usage
TODO

## Object Serialization
TODO
