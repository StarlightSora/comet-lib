## AnimationLibrary that can be edited in the editor.
@tool
class_name CometAnimationLibrary
extends AnimationLibrary

## Dictionary<StringName, Animation>
@export var animations: Dictionary[StringName, Animation]:
	set(u):
		animations = u
		_repopulate()

func _empty() -> void:
	for entry_name in get_animation_list():
		remove_animation(entry_name)
		#print("removed ", entry_name)

func _fill() -> void:
	for entry_name in animations:
		var e := add_animation(entry_name, animations[entry_name])
		if e != OK:
			push_warning("CometAnimationLibrary failed to add animation ", entry_name, " with error ", e, ": ", error_string(e))
		#else:
			#print("added ", entry_name)

func _repopulate() -> void:
	_empty()
	_fill()
