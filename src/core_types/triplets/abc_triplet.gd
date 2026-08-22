class_name ABCTriplet
extends AbstractABCTriplet

@export var _a: Variant
@export var _b: Variant
@export var _c: Variant

## (T, U, V) -> ABCTriplet<T, U, V>
func _init(first: Variant = null, second: Variant = null, third: Variant = null) -> void:
    _a = first
    _b = second
    _c = third

## () -> T
func a() -> Variant:
    return _a

## () -> U
func b() -> Variant:
    return _b

## () -> V
func c() -> Variant:
    return _c

## mut (T) -> T
func mut_a(new_a: Variant) -> Variant:
    var temp: Variant = _a
    _a = new_a
    return temp

## mut (U) -> U
func mut_b(new_b: Variant) -> Variant:
    var temp: Variant = _b
    _b = new_b
    return temp

## mut (V) -> V
func mut_c(new_c: Variant) -> Variant:
    var temp: Variant = _c
    _c = new_c
    return temp

## mut (Func(T) -> T) -> T
func call_a(to_call: Callable) -> Variant:
    var temp: Variant = _a
    _a = to_call.call(_a)
    return temp

## mut (Func(U) -> U) -> U
func call_b(to_call: Callable) -> Variant:
    var temp: Variant = _b
    _b = to_call.call(_b)
    return temp

## mut (Func(V) -> V) -> V
func call_c(to_call: Callable) -> Variant:
    var temp: Variant = _c
    _c = to_call.call(_c)
    return temp