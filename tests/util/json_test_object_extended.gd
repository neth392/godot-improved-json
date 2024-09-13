## Contains additional properties for testing
class_name JSONTestObjectExtended extends JSONTestObject

var type_object: Object  = JSONTestObject.new()
var type_untyped_array_of_objects: Array = [JSONTestObject.new(), JSONTestObject.new(), JSONTestObject.new()]
var type_typed_array_of_objects: Array[JSONTestObject] = [JSONTestObject.new(), JSONTestObject.new(), JSONTestObject.new()]
var type_array_of_array_of_objects: Array[Array] = [[JSONTestObject.new(), JSONTestObject.new()], 
[JSONTestObject.new()], [JSONTestObject.new(), JSONTestObject.new(), JSONTestObject.new()]]
var type_untyped_dictionary_of_objects: Dictionary = {
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
}
var type_typed_dictionary_of_objects: Dictionary[JSONTestObject, JSONTestObject] = {
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
}
var type_key_typed_dictionary_of_objects: Dictionary[JSONTestObject, Variant] = {
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
}
var type_value_typed_dictionary_of_objects: Dictionary[Variant, JSONTestObject] = {
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
	JSONTestObject.new(): JSONTestObject.new(),
}
