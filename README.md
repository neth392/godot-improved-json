# Godot Improved JSON

![Godot-JSON Icon](icon.svg)

Godot Improved JSON is a Godot 4.4 (or later) addon that provides seamless methods of serializing any variant, including Objects and their properties.

## Table of Contents
- [Why?](#Why)
- [Support Links](#Support-Links)
- [Installation](#Installation)
- [Limitations](#Limitations)
- [Basic Usage](#Basic-Usage)
- [Object Serialization](#Object-Serialization)

## Why?
Originally this project was created to bring JSON support to all of Godot's native types, including Objects & their properties. But with [Godot 4.4-dev2](https://godotengine.org/article/dev-snapshot-godot-4-4-dev-2/)'s release, [this commit](https://github.com/godotengine/godot/pull/92656) was merged doing just that. However, after testing the new changes there were still issues that this project solves, predominantly in regards to Objects.

The current issues with Godot's new JSON changes that this project addresses are:
- `JSON.stringify(variant)` and `JSON.parse(variant)` do not detect the variant's type, it is redundantly required to use `JSON.stringify(JSON.from_native(variant))` and `JSON.to_native(JSON.parse(variant))`. Improved JSON automatically detects any variant's type and serializes it accordingly, without the need for boilerplate.
- JSON Object support for custom objects in native Godot is still questionable, and currently appears broken. In the above point, if `variant` were to be an instance of `MyCustomClass`, when you deserialize it you will not receive an instance of `MyCustomClass`, just an instance of its base type (such as Resource). There is no property way to simply convert your objects to JSON & back without your own boilerplate, which this project aims to eliminate.
- A lot of internal properties that you don't need serialized are included Godot's `JSON.to_native` function. With this project, you tell the system what should be serialized. This tremendously cuts down the file sizes and speeds up load times. But most importantly it ensures your saving & loading behave how *you* want it to.
- Godot 4.4's new `JSON.from_native()` method returns a Dictionary that contains fully spelled out keys such as `__gdtype` for the `Variant.Type`, `basis` and `origin` for `Transform3D`'s values, & more. Improved Godot JSON uses short, one character keys. Again, this increases efficiency and reduces file size, which can add up when dealing with larger JSON files.


## Support Links
For now, message me on Discord for direct support: cneth

## Installation
TODO

## Limitations
- Serialized objects **must** have an explicit `class_name` defined in their script.
- Nested/inner classes are **not supported**
- A `JSONObjectConfigRegistry` file somewhere in the project directory is **required**. Object serialization will not work without it, but the addon *shouldn't* break completely.
- `TYPE_NIL`, `TYPE_CALLABLE`, `TYPE_SIGNAL`, `TYPE_RID`, & `TYPE_MAX`  are **not supported**.
- There is currently a bug that causes the `JSONSerialization` autoload to have it's `_ready()` function called twice in the editor when the project is opened. I have tried everything to fix this and I can not figure it out. This shouldn't noticeably impact anything.

## Basic Usage
TODO

## Object Serialization
TODO


[Back to Top ↑](#Godot-Improved-JSON)