## Uses the class name of a godot-native object type to create an instance of it. Dose not
## work with non-native types as it relies on [ClassDB].
class_name JSONNativeObjectInstantiator extends JSONInstantiator

## The class to be instantiated. Must be an [Object] & must be able to be instantiated
## by [method ClassDB.instantiate].
@export_custom(PROPERTY_HINT_TYPE_STRING, &"Object") var _class: String:
	set(value):
		if !_class.is_empty():
			assert(ClassDB.class_exists(value), "Class %s is not a native godot class" % _class)
			assert(ClassDB.can_instantiate(value), ("Class %s can't be instantiated, write a " + \
			"custom JSONInstantiator implementation for it") % _class)
			assert(ClassDB.is_parent_class(value, &"Object"), ("Class %s does not extend Object " +\
			"and thus can't be instantiated") % _class)
		
		_class = value


func _can_instantiate() -> bool:
	return ClassDB.can_instantiate(_class)


func _instantiate() -> Object:
	return ClassDB.instantiate(_class)
