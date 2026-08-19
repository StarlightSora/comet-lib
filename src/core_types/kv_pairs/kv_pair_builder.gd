class_name KVPairBuilder
extends AbstractKVPairBuilder

## () -> KVPairBuilder
func _init() -> void:
    pass

## (Dictionary<T, U>, type A?) -> Array<A<T, U>>
## where A: default KVPair, extends AbstractKVPair
##
## Note: You would likely want to explicitly downcast the returned reference as "`Array[A]`" in your call site.
func dict_to_arr(dict: Dictionary[Variant, Variant], make_as: Object = KVPair) -> Array[AbstractKVPair]:
    var arr: Array[AbstractKVPair] = []
    arr.resize(dict.size())
    var i: int = 0
    for key in dict:
        arr[i] = make_as.new(key, dict[key])
        i += 1
    return arr

## (Array<A<T, U>>) -> Dictionary<T, U>
## where A: extends AbstractKVPair
##
## Note: You would likely want to explicitly downcast the returned reference as "`Dictionary[T, U]`" in your call site.
func arr_to_dict(arr: Array[AbstractKVPair]) -> Dictionary[Variant, Variant]:
    var dict: Dictionary[Variant, Variant] = { }
    for value in arr:
        dict.set(value.k(), value.v())
    return dict