class_name CometScalarUtil
extends RefCounted

const _ERF_A1 = 0.254829592
const _ERF_A2 = -0.284496736
const _ERF_A3 = 1.421413741
const _ERF_A4 = -1.453152027
const _ERF_A5 = 1.061405429
const _ERF_P = 0.3275911

## (float) -> OptionalType<float>
##
## TIP: Use `.unwrap_or(default_value)` in the call site to convert this back to a non-nullable `float`,
## where it resolves to `default_value` if `to_check` was `NAN`, else it resolves to `to_check`.
func maybe_nan_to_optional(to_check: float) -> OptionalType:
	if is_nan(to_check): return OptionalType.new(null)
	else: return OptionalType.new(to_check)

## (float) -> OptionalType<float>
func maybe_nan_or_inf_to_optional(to_check: float) -> OptionalType:
	if is_nan(to_check): return OptionalType.new(null)
	elif not is_finite(to_check): return OptionalType.new(null)
	else: return OptionalType.new(to_check)

## (float, float) -> OptionalType<float>
##
## Return value will be `is_none()` if `rhs == 0.0` or `NAN` was produced during calculation.
func safe_div(lhs: float, rhs: float) -> OptionalType:
	if rhs == 0.0:
		return OptionalType.new(null)
	else:
		return maybe_nan_to_optional(lhs / rhs)

## (float, float) -> float
##
## Equivalent to `log(product) / log(base)`.
func logbase(product: float, base: float) -> float:
	return log(product) / log(base)

## (float, float) -> OptionalType<float>
##
## Return value will be `is_none()`
## if `product < 0.0 or base < 0.0`, or if `NAN` was produced during calculation.
func safe_logbase(product: float, base: float) -> OptionalType:
	if product < 0.0 or base < 0.0: return OptionalType.new(null)
	return maybe_nan_to_optional(log(product) / log(base))

var _fn_sum := func(ac: float, v: float) -> float: return ac + v
## (Array<float>) -> float
func sum(arr: Array[float]) -> float:
	return arr.reduce(_fn_sum)

## (Array<float>) -> float
func avg(arr: Array[float]) -> float:
	return sum(arr) / arr.size()

## (Array<float>) -> OptionalType<float>
##
## Return value will be `is_none()` if the input array is empty or `NAN` was produced during calculation.
func safe_avg(arr: Array[float]) -> OptionalType:
	if arr.size() <= 0: return OptionalType.new(null)
	return maybe_nan_to_optional(sum(arr) / arr.size())

## (Array<float>) -> float
##
## NOTE: Has O(n) space complexity.
func med(arr: Array[float]) -> float:
	# Technically this could be done with O(1) space complexity with a selection algorithm (I think?),
	# but I cannot be bothered. Will refactor later if needed.
	var clo: Array[float] = arr.duplicate_deep()
	clo.sort()
	if clo.size() % 2 == 0:
		@warning_ignore("integer_division") # REASON: clo.size() is always be a multiple of 2, so no information is lost when dividing it by 2
		return (clo[clo.size() / 2] + clo[clo.size() / 2 - 1]) / 2.0
	else:
		return clo[floori(clo.size() as float / 2)]

## (Array<float>) -> OptionalType<float>
##
## Return value will be `is_none()` if the input array is empty or `NAN` was produced during calculation.
func safe_med(arr: Array[float]) -> OptionalType:
	if arr.size() <= 0: return OptionalType.new(null)
	var clo: Array[float] = arr.duplicate_deep()
	clo.sort()
	if clo.size() % 2 == 0:
		@warning_ignore("integer_division")
		return maybe_nan_to_optional((clo[clo.size() / 2] + clo[clo.size() / 2 - 1]) / 2.0)
	else:
		return maybe_nan_to_optional(clo[floori(clo.size() as float / 2)])

## (Array<float>) -> Array[float]
##
## The entire array is returned if there's no mode in the array. The order may not be the same as the input array.
func mod(arr: Array[float]) -> Array[float]:
	if arr.size() <= 0: return []
	var counter: Dictionary[float, int] = {}
	for v in arr:
		if not counter.has(v):
			counter.set(v, 1)
		else:
			counter[v] += 1
	var highest_count: int = 0
	for i in counter:
		if counter[i] > highest_count:
			highest_count = counter[i]
	var to_return: Array[float] = []
	for i in counter:
		if counter[i] >= highest_count:
			to_return.push_back(i)
	return to_return

## (Array<float>) -> float
func vari(arr: Array[float]) -> float:
	var _avg: float = avg(arr)
	var ac: float = 0
	for v in arr:
		ac += pow(v - _avg, 2)
	return ac / arr.size()

## (Array<float>) -> OptionalType<float>
##
## Return value will be `is_none()` if the input array is empty or `NAN` was produced during calculation.
func safe_vari(arr: Array[float]) -> OptionalType:
	if arr.size() <= 0: return OptionalType.new(null)
	var _avg: float = avg(arr)
	var ac: float = 0
	for v in arr:
		ac += pow(v - _avg, 2)
	return maybe_nan_to_optional(ac / arr.size())

## (Array<float>) -> float
func stdev(arr: Array[float]) -> float:
	return sqrt(vari(arr))

## (Array<float>) -> OptionalType<float>
##
## Return value will be `is_none()` if the input array is empty or `NAN` was produced during calculation.
func safe_stdev(arr: Array[float]) -> OptionalType:
	return safe_vari(arr).map(sqrt)

## (float) -> float
##
## Get the approximate value of the Error Function at x.
func erf(x: float) -> float:
	var erf_sign = -1 if x < 0 else 1
	var absx = abs(x)
	var t = 1.0 / (1.0 + _ERF_P * absx)
	var y = 1.0 - (((((_ERF_A5 * t + _ERF_A4) * t) + _ERF_A3) * t + _ERF_A2) * t + _ERF_A1) * t * exp(-absx * absx)
	return erf_sign * y

## (float, float?, float?) -> float
##
## Get the normal distribution's Probability Density Function value at x.
func norm_pdf(x: float, mu: float = 0.0, sigma: float = 1.0) -> float:
	var coeff: float = 1.0 / (sigma * sqrt(2*PI))
	var exponent: float = -pow(x - mu, 2) / (2.0 * pow(sigma, 2))
	return coeff * exp(exponent)

## (float, float?, float?) -> float
##
## Get the approximate normal distribution's Cumulative Distributive Function value at x.
func norm_cdf(x: float, mu: float = 0.0, sigma: float = 1.0) -> float:
	var z = (x - mu) / (sigma * sqrt(2.0))
	return 0.5 * (1.0 + erf(z))
