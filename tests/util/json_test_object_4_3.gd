## Object used in Gut tests.
## Most properties here should account for testing of every possible type, except objects.
## For objects, see [JSONTestObjectExtended]
class_name JSONTestObject_4_3 extends RefCounted

var type_bool: bool = true
var type_int: int = 42
var type_float: float = 3.14
var type_string: String = "Hello, Godot!"
var type_vector2: Vector2 = Vector2(1.0, 2.0)
var type_vector2i: Vector2i = Vector2i(1, 2)
var type_rect2: Rect2 = Rect2(Vector2(0, 0), Vector2(100, 50))
var type_rect2i: Rect2i = Rect2i(Vector2i(0, 0), Vector2i(100, 50))
var type_vector3: Vector3 = Vector3(1.0, 2.0, 3.0)
var type_vector3i: Vector3i = Vector3i(1, 2, 3)
var type_transform2d: Transform2D = Transform2D(1, Vector2(10, 20))
var type_vector4: Vector4 = Vector4(1.0, 2.0, 3.0, 4.0)
var type_vector4i: Vector4i = Vector4i(1, 2, 3, 4)
var type_plane: Plane = Plane(Vector3(1.0, 0.0, 0.0), 2.0)
var type_quaternion: Quaternion = Quaternion(Vector3(1, 0, 0), deg_to_rad(90.0))
var type_aabb: AABB = AABB(Vector3(0, 0, 0), Vector3(5, 5, 5))
var type_basis: Basis = Basis(Vector3(0, 1, 0), deg_to_rad(45.0))
var type_transform3d: Transform3D = Transform3D()
var type_color: Color = Color.LIME
var type_string_name: StringName = StringName("example")
var type_node_path: NodePath = NodePath("/root/Node")
var type_packed_byte_array: PackedByteArray = PackedByteArray([0x01, 0x02, 0x03])
var type_packed_int32_array: PackedInt32Array = PackedInt32Array([1, 2, 3])
var type_packed_int64_array: PackedInt64Array = PackedInt64Array([1, 2, 3])
var type_packed_float32_array: PackedFloat32Array = PackedFloat32Array([1.0, 2.0, 3.0])
var type_packed_float64_array: PackedFloat64Array = PackedFloat64Array([1.0, 2.0, 3.0])
var type_packed_string_array: PackedStringArray = PackedStringArray(["apple", "banana", "cherry"])
var type_packed_vector2_array: PackedVector2Array = PackedVector2Array([Vector2(1.0, 2.0), 
Vector2(3.0, 4.0)])
var type_packed_vector3_array: PackedVector3Array = PackedVector3Array([Vector3(1.0, 2.0, 3.0), 
Vector3(4.0, 5.0, 6.0)])
var type_packed_vector4_array: PackedVector4Array = PackedVector4Array([Vector4(1.0, 2.0, 3.0, 4.0), 
Vector4(5.0, 6.0, 7.0, 8.0)])
var type_packed_color_array: PackedColorArray = PackedColorArray([Color.RED, Color.ORANGE,
Color.YELLOW, Color.GREEN, Color.BLUE, Color.PURPLE])
var type_int_array_of_ints: Array[int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
var type_array_of_random_arrays: Array[Array] = [[1, 2, 3, 4, 5, 6], ["hi!", "hello!", "test"], 
[2.0, 1, Vector2(1.0, 2.0)], ["string", 1.0, 2, true, NodePath("/root/Node/AnotherNode")]]
var type_untyped_dictionary: Dictionary = {"yo": Vector3(1.0,2.0,3.0), 2: -4.0, Color.RED: false}
var type_empty_untyped_array: Array = []
var type_empty_typed_array: Array[Node] = []
var empty_untyped_dictionary: Dictionary = {}
