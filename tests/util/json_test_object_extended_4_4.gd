## Contains additional properties for testing
class_name JSONTestObjectExtended_4_4 extends JSONTestObject_4_4

var type_object: Object  = JSONTestObject_4_4.new()
var type_untyped_array_of_objects: Array = [JSONTestObject_4_4.new(), JSONTestObject_4_4.new(), JSONTestObject_4_4.new()]
var type_typed_array_of_objects: Array[JSONTestObject_4_4] = [JSONTestObject_4_4.new(), JSONTestObject_4_4.new(), JSONTestObject_4_4.new()]
var type_array_of_array_of_objects: Array[Array] = [[JSONTestObject_4_4.new(), JSONTestObject_4_4.new()], 
[JSONTestObject_4_4.new()], [JSONTestObject_4_4.new(), JSONTestObject_4_4.new(), JSONTestObject_4_4.new()]]
var type_untyped_dictionary_of_objects: Dictionary = {
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
}
var type_typed_dictionary_of_objects: Dictionary[JSONTestObject_4_4, JSONTestObject_4_4] = {
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
}
var type_key_typed_dictionary_of_objects: Dictionary[JSONTestObject_4_4, Variant] = {
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
}
var type_value_typed_dictionary_of_objects: Dictionary[Variant, JSONTestObject_4_4] = {
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
	JSONTestObject_4_4.new(): JSONTestObject_4_4.new(),
}
var type_weak_ref: WeakRef = weakref(type_object)
var type_weak_ref_null: WeakRef = weakref(null)
var type_nested_weak_ref: WeakRef = weakref(type_weak_ref)
var type_nested_twice_weak_ref: WeakRef = weakref(type_nested_weak_ref)
