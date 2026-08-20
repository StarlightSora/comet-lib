class_name CometTransformUtil
extends RefCounted

const INVALID_T3D: Transform3D = Transform3D(Basis(Quaternion(NAN, NAN, NAN, NAN)), Vector3(NAN, NAN, NAN))

enum BTBlendMode {
	BLEND_WITH_ORIGIN_IF_WEIGHT_UNDER_ONE,
	ONLY_USE_ORIGIN_IF_WEIGHT_IS_ZERO,
	NEVER_USE_ORIGIN,
}

## (Transform2D) -> OptionalType<Transform2D>
func maybe_infinite_t2d_to_optional(to_check: Transform2D) -> OptionalType:
	if to_check.is_finite():
		return OptionalType.new(to_check)
	else:
		return OptionalType.new(null)

## (Transform3D) -> OptionalType<Transform3D>
func maybe_infinite_t3d_to_optional(to_check: Transform3D) -> OptionalType:
	if to_check.is_finite():
		return OptionalType.new(to_check)
	else:
		return OptionalType.new(null)

static var _bt3d := func(lhs: KVPair, rhs: KVPair) -> bool:
	return lhs.k() < rhs.k()
## (Dictionary<T, Transform3D>, Dictionary<T, float>, Transform3D?, BTBlendMode?) -> Transform3D
##
## `blend_mode` defaults to `BLEND_WITH_ORIGIN_IF_WEIGHT_UNDER_ONE`.
## Negative weights are not supported; such entries will be ignored.
## The blending is *not* mathematically proven to be truly linear with more than two entries.
##
## NOTE: The return value will be an invalid Transform3D if `blend_mode = NEVER_USE_ORIGIN` and the total weight of the `weights` array is zero.
## To safely guard against this possibility, wrap the return value in a `maybe_infinite_t3d_to_optional` call to convert it to an `OptionalType<Transform3D>`.
##
## Has O(n) time complexity.
func blend_transform3ds(
	targets: Dictionary[Variant, Transform3D],
	weights: Dictionary[Variant, float],
	origin: Transform3D = Transform3D.IDENTITY,
	blend_mode: BTBlendMode = BTBlendMode.BLEND_WITH_ORIGIN_IF_WEIGHT_UNDER_ONE,
) -> Transform3D:
	var transposed: Array[KVPair] = [] ## Array<KVPair<float, Transform3D>>
	var total_weight: float = 0.0
	var total_entries: int = 0
	for key in weights:
		var value: float = weights[key]
		if value > 0.0:
			if not targets.has(key):
				push_warning(str(key) + " is missing in the targets dictionary, so it will be ignored!")
				continue
			total_weight += value
			transposed.push_back(KVPair.new(value, targets[key]))
			total_entries += 1
	match total_entries:
		0:
			if blend_mode == BTBlendMode.NEVER_USE_ORIGIN:
				return INVALID_T3D
			else:
				return origin
		1:
			if total_weight <= 1.0 and blend_mode == BTBlendMode.BLEND_WITH_ORIGIN_IF_WEIGHT_UNDER_ONE:
				return origin.interpolate_with(transposed[0].v(), total_weight)
			else:
				return transposed[0].v()
		2:
			if total_weight <= 1.0 and blend_mode == BTBlendMode.BLEND_WITH_ORIGIN_IF_WEIGHT_UNDER_ONE:
				return origin.interpolate_with(
					transposed[0].v().interpolate_with(
						transposed[1].v(),
						transposed[1].k() / total_weight,
					),
					total_weight,
				)
			else:
				return transposed[0].v().interpolate_with(
					transposed[1].v(),
					transposed[1].k() / total_weight,
				)
		_:
			# We treat the array as a queue to iteratively blend the transforms until it's blended to one transform.
			# We sort in ascending order to blend the smaller weights first to minimize artifacting.
			# This results in O(n) time complexity. For example, with 2^5 weights:
			# 2^5 + 2^4 + 2^3 + 2^2 + 2^1 + 2^0 = 2^5 * 2 - 1 iterations.
			transposed.sort_custom(_bt3d)
			while transposed.size() > 0:
				var front_0: KVPair = transposed.pop_front() ## KVPair<float, Transform3D>
				var front_1: KVPair = transposed.pop_front() ## KVPair<float, Transform3D>?
				if front_1:
					var sum = front_0.k() + front_1.k()
					transposed.push_back(KVPair.new(
						sum,
						front_0.v().interpolate_with(front_1.v(), front_1.k() / sum),
					))
				else:
					if total_weight <= 1.0 and blend_mode == BTBlendMode.BLEND_WITH_ORIGIN_IF_WEIGHT_UNDER_ONE:
						return origin.interpolate_with(front_0.v(), total_weight)
					else:
						return front_0.v()
	assert(false, "Unreachable code!")
	return INVALID_T3D if blend_mode == BTBlendMode.NEVER_USE_ORIGIN else origin

