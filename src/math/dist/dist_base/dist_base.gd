class_name DistBase
extends Resource

@export var scale: float = 1.0

## (float?) -> DistBase
func _init(new_scale: float = 1.0) -> void:
	scale = new_scale

## (float) -> float
func get_value_at(_x: float) -> float:
	return scale
