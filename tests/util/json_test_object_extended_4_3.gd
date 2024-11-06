## Contains additional properties for testing
class_name JSONTestObjectExtended_4_3 extends JSONTestObject_4_3

var type_object: Object  = JSONTestObject_4_3.new()
var type_untyped_array_of_objects: Array = [JSONTestObject_4_3.new(), JSONTestObject_4_3.new(), JSONTestObject_4_3.new()]
var type_typed_array_of_objects: Array[JSONTestObject_4_3] = [JSONTestObject_4_3.new(), JSONTestObject_4_3.new(), JSONTestObject_4_3.new()]
var type_array_of_array_of_objects: Array[Array] = [[JSONTestObject_4_3.new(), JSONTestObject_4_3.new()], 
[JSONTestObject_4_3.new()], [JSONTestObject_4_3.new(), JSONTestObject_4_3.new(), JSONTestObject_4_3.new()]]
var type_untyped_dictionary_of_objects: Dictionary = {
	JSONTestObject_4_3.new(): JSONTestObject_4_3.new(),
	JSONTestObject_4_3.new(): JSONTestObject_4_3.new(),
	JSONTestObject_4_3.new(): JSONTestObject_4_3.new(),
}
var type_weak_ref: WeakRef = weakref(type_object)
var type_weak_ref_null: WeakRef = weakref(null)
var type_nested_weak_ref: WeakRef = weakref(weakref(type_object))
var type_nested_twice_weak_ref: WeakRef = weakref(weakref(weakref(type_object)))
