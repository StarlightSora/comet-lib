class_name NormDistCollection
extends DistCollectionBase

## (Array[NormDist], float?, float?, float?, bool?) -> NormDistCollection<NormDist>
func _init(norm_dist_array: Array[DistBase] = [], global_offset: float = 0.0, global_scale: float = 1.0, allow_negative_results: bool = false) -> void:
	super._init(norm_dist_array as Array[DistBase], global_offset, global_scale, allow_negative_results)
