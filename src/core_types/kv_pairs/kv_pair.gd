class_name KVPair
extends AbstractKVPair

@export var _key: Variant
@export var _value: Variant

## (T, U) -> KVPair<T, U>
func _init(key: Variant = null, value: Variant = null) -> void:
    _key = key
    _value = value

## () -> T
func k() -> Variant:
    return _key

## () -> U
func v() -> Variant:
    return _value

## mut (T) -> T
func mut_k(new_key: Variant) -> Variant:
    var temp: Variant = _key
    _key = new_key
    return temp

## mut (U) -> U
func mut_v(new_value: Variant) -> Variant:
    var temp: Variant = _value
    _value = new_value
    return temp