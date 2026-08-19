class_name DistCollectionBase
extends Resource

@export var dist_array: Array[DistBase] = []
@export var offset: float = 0.0
@export var scale: float = 1.0
@export var allow_negative: bool = false

## (Array[DistBase], float?, float?, float?, bool?) -> DistCollectionBase<DistBase>
func _init(generic_dist_array: Array[DistBase] = [], global_offset: float = 0.0, global_scale: float = 1.0, allow_negative_results: bool = false) -> void:
	dist_array = generic_dist_array
	offset = global_offset
	scale = global_scale
	allow_negative = allow_negative_results

## (float) -> float
func get_value_at(x: float) -> float:
	var value: float = offset
	for v: DistBase in dist_array:
		value += v.get_value_at(x)
	
	if allow_negative:
		return value * scale
	else:
		return max(0.0, value) * scale
