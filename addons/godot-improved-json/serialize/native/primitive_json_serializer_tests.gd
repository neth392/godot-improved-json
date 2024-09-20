## Debug class used to test which types work with [PrimitiveJSONSerializer].
extends Node

@export var script_to_test: Script

var types_dict: Dictionary = {
	TYPE_NIL: "TYPE_NIL",
	TYPE_BOOL: "TYPE_BOOL",
	TYPE_INT: "TYPE_INT",
	TYPE_FLOAT: "TYPE_FLOAT",
	TYPE_STRING: "TYPE_STRING",
	TYPE_VECTOR2: "TYPE_VECTOR2",
	TYPE_VECTOR2I: "TYPE_VECTOR2I",
	TYPE_RECT2: "TYPE_RECT2",
	TYPE_RECT2I: "TYPE_RECT2I",
	TYPE_VECTOR3: "TYPE_VECTOR3",
	TYPE_VECTOR3I: "TYPE_VECTOR3I",
	TYPE_TRANSFORM2D: "TYPE_TRANSFORM2D",
	TYPE_VECTOR4: "TYPE_VECTOR4",
	TYPE_VECTOR4I: "TYPE_VECTOR4I",
	TYPE_PLANE: "TYPE_PLANE",
	TYPE_QUATERNION: "TYPE_QUATERNION",
	TYPE_AABB: "TYPE_AABB",
	TYPE_BASIS: "TYPE_BASIS",
	TYPE_TRANSFORM3D: "TYPE_TRANSFORM3D",
	TYPE_PROJECTION: "TYPE_PROJECTION",
	TYPE_STRING_NAME: "TYPE_STRING_NAME",
	TYPE_NODE_PATH: "TYPE_NODE_PATH",
	TYPE_PACKED_BYTE_ARRAY: "TYPE_PACKED_BYTE_ARRAY",
	TYPE_PACKED_INT32_ARRAY: "TYPE_PACKED_INT32_ARRAY",
	TYPE_PACKED_INT64_ARRAY: "TYPE_PACKED_INT64_ARRAY",
	TYPE_PACKED_FLOAT32_ARRAY: "TYPE_PACKED_FLOAT32_ARRAY",
	TYPE_PACKED_FLOAT64_ARRAY: "TYPE_PACKED_FLOAT64_ARRAY",
	TYPE_PACKED_STRING_ARRAY: "TYPE_PACKED_STRING_ARRAY",
	TYPE_PACKED_VECTOR2_ARRAY: "TYPE_PACKED_VECTOR2_ARRAY",
	TYPE_PACKED_VECTOR3_ARRAY: "TYPE_PACKED_VECTOR3_ARRAY",
	TYPE_PACKED_COLOR_ARRAY: "TYPE_PACKED_COLOR_ARRAY",
	TYPE_PACKED_VECTOR4_ARRAY: "TYPE_PACKED_VECTOR4_ARRAY",
}

var type_examples: Dictionary = {
	TYPE_NIL: null,  # Example for NIL type
	TYPE_BOOL: true,  # Example for BOOL type
	TYPE_INT: 42,  # Example for INT type
	TYPE_FLOAT: 3.14,  # Example for FLOAT type
	TYPE_STRING: "example",  # Example for STRING type
	TYPE_VECTOR2: Vector2(1.5, 2.5),  # Example for VECTOR2 type
	TYPE_VECTOR2I: Vector2i(1, 2),  # Example for VECTOR2I type
	TYPE_RECT2: Rect2(10, 20, 100, 200),  # Example for RECT2 type
	TYPE_RECT2I: Rect2i(10, 20, 100, 200),  # Example for RECT2I type
	TYPE_VECTOR3: Vector3(1.5, 2.5, 3.5),  # Example for VECTOR3 type
	TYPE_VECTOR3I: Vector3i(1, 2, 3),  # Example for VECTOR3I type
	TYPE_TRANSFORM2D: Transform2D(2.0, Vector2(1, 1)),  # Example for TRANSFORM2D type with scale and position
	TYPE_VECTOR4: Vector4(1.0, 2.0, 3.0, 4.0),  # Example for VECTOR4 type
	TYPE_VECTOR4I: Vector4i(1, 2, 3, 4),  # Example for VECTOR4I type
	TYPE_PLANE: Plane(Vector3(0, 1, 0), 10),  # Example for PLANE type with normal and distance
	TYPE_QUATERNION: Quaternion(1, 0, 0, 0),  # Example for QUATERNION type
	TYPE_AABB: AABB(Vector3(0, 0, 0), Vector3(1, 1, 1)),  # Example for AABB type with position and size
	TYPE_BASIS: Basis(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)),  # Example for BASIS type with basis vectors
	TYPE_TRANSFORM3D: Transform3D(Basis(), Vector3(1, 2, 3)),  # Example for TRANSFORM3D type with basis and origin
	TYPE_PROJECTION: Projection(),  # Projection matrix example with default identity matrix
	TYPE_COLOR: Color.NAVAJO_WHITE,  # Example for COLOR type with RGBA values
	TYPE_STRING_NAME: StringName("example_name"),  # Example for STRING_NAME type
	TYPE_NODE_PATH: NodePath("/root/ExampleNode"),  # Example for NODE_PATH type
	#TYPE_OBJECT: Object.new(),  # Example for OBJECT type, a generic new Object
	TYPE_DICTIONARY: {"key": "value", "number": 42},  # Example for DICTIONARY type with mixed key-value pairs
	TYPE_ARRAY: [1, "two", 3.0],  # Example for ARRAY type with mixed types
	TYPE_PACKED_BYTE_ARRAY: PackedByteArray([0x00, 0xFF, 0x7F]),  # Example for PACKED_BYTE_ARRAY type
	TYPE_PACKED_INT32_ARRAY: PackedInt32Array([100, 200, 300]),  # Example for PACKED_INT32_ARRAY type
	TYPE_PACKED_INT64_ARRAY: PackedInt64Array([10000000000, 20000000000, 30000000000]),  # Example for PACKED_INT64_ARRAY type
	TYPE_PACKED_FLOAT32_ARRAY: PackedFloat32Array([1.1, 2.2, 3.3]),  # Example for PACKED_FLOAT32_ARRAY type
	TYPE_PACKED_FLOAT64_ARRAY: PackedFloat64Array([1.123456789, 2.234567891, 3.345678912]),  # Example for PACKED_FLOAT64_ARRAY type
	TYPE_PACKED_STRING_ARRAY: PackedStringArray(["one", "two", "three"]),  # Example for PACKED_STRING_ARRAY type
	TYPE_PACKED_VECTOR2_ARRAY: PackedVector2Array([Vector2(1.5, 2.5), Vector2(3.5, 4.5)]),  # Example for PACKED_VECTOR2_ARRAY type
	TYPE_PACKED_VECTOR3_ARRAY: PackedVector3Array([Vector3(1, 2, 3), Vector3(4, 5, 6)]),  # Example for PACKED_VECTOR3_ARRAY type
	TYPE_PACKED_COLOR_ARRAY: PackedColorArray([Color(1, 0, 0), Color(0, 1, 0)]),  # Example for PACKED_COLOR_ARRAY type
	TYPE_PACKED_VECTOR4_ARRAY: PackedVector4Array([Vector4(1, 2, 3, 4), Vector4(5, 6, 7, 8)]),  # Example for PACKED_VECTOR4_ARRAY type
}


var supported_types: Dictionary = {}


func _ready() -> void:
	for type: Variant.Type in types_dict:
		var type_name: String = types_dict[type]
		var serializer: JSONSerializer = PrimitiveJSONSerializer.new(type)
		var value: Variant = type_examples[type]
		assert(type == typeof(value), "type example mismatch for type %s" % type_name)
		
		JSONSerialization.add_serializer(serializer)
		
		var json_string: String = JSONSerialization.stringify(value)
		var parsed: Variant = JSONSerialization.parse(json_string)
		
		JSONSerialization.remove_serializer(serializer)
		
		var type_match: bool = typeof(value) == typeof(parsed)
		var equals: bool = value == parsed
		
		if type_match && equals:
			supported_types[type_name] = parsed
		
		print("TEST %s, TYPE MATCH=%s, EQUALS=%s, PARSED=%s" % [type_name, type_match, equals, parsed])
	
	print("\n\n")
	print("SUPPORTED TYPES: ")
	for st: String in supported_types:
		var type: Variant.Type = typeof(supported_types[st])
		print(st + " value=" + str(type_examples[type]) + " parsed= " + str(supported_types[st]) + ", type= " + types_dict[type])
