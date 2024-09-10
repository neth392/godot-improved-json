## Instantiator that creates an instance from a [PackedScene]
@tool
class_name JSONSceneInstantiator extends JSONInstantiator

@export var scene: PackedScene:
	set(value):
		if value != null:
			assert(value.can_instantiate(), "cant instantiate scene %s" % value)
		scene = value


func _can_instantiate() -> bool:
	return scene != null && scene.can_instantiate()


func _instantiate() -> Object:
	assert(scene != null, "scene is null (not set)")
	assert(scene.can_instantiate(), "cant instantiate scene %s" % scene)
	return scene.instantiate()
