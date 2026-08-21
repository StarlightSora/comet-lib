## pureClass
class_name KVPairUtil
extends AbstractKVPairUtil

## (Dictionary<T, U>, type A?) -> Array<A<T, U>>
## where A: default KVPair, extends AbstractKVPair
##
## Note: You would likely want to explicitly downcast the returned reference as "`Array[A]`" at your call site.
static func dict_to_arr(dict: Dictionary[Variant, Variant], make_as: Object = KVPair) -> Array[AbstractKVPair]:
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
## Note: You would likely want to explicitly downcast the returned reference as "`Dictionary[T, U]`" at your call site.
static func arr_to_dict(arr: Array[AbstractKVPair]) -> Dictionary[Variant, Variant]:
    var dict: Dictionary[Variant, Variant] = { }
    for value in arr:
        dict.set(value.k(), value.v())
    return dict

## (Array<T or U>, type A?) -> A<T, U>
## where A: default KVPair, extends AbstractKVPair
##
## Note: The 0th element of `arr` is `T`, the 1st element is `U`. Any extra elements will be ignored.
static func transpose_to_kv(arr: Array[Variant], make_as: Object = KVPair) -> AbstractKVPair:
    return make_as.new(arr[0], arr[1])

## transpose_from_kv(A<T, U>) -> Array<T or U>
## where A: extends AbstractKVPair
##
## Note: The 0th element of the returning reference is `T`, the 1st element is `U`.
static func transpose_from_kv(kv: AbstractKVPair) -> Array[Variant]:
    return [kv.k(), kv.v()]