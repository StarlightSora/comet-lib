class_name NormDist
extends DistBase

@export var mu: float = 0.0
@export var sigma: float = 1.0
@export var cumulative: bool = false
@export var flipped: bool = false

var _CSU = CometScalarUtil.new()

## (float?, float?, float?, bool?, bool?) -> NormDist
func _init(new_mu: float = 0.0, new_sigma: float = 1.0, new_scale: float = 1.0, is_cumulative: bool = false, cumulative_flipped: bool = false) -> void:
	mu = new_mu
	sigma = new_sigma
	scale = new_scale
	cumulative = is_cumulative
	flipped = cumulative_flipped

## (float) -> float
func get_value_at(x: float) -> float:
	if cumulative:
		if flipped:
			return (1 - _CSU.norm_cdf(x, mu, sigma)) * scale
		else:
			return _CSU.norm_cdf(x, mu, sigma) * scale
	else:
		return _CSU.norm_pdf(x, mu, sigma) * scale
