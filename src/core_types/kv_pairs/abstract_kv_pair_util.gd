## pureClass
@abstract class_name AbstractKVPairUtil
extends Resource

## Contracts:
##
## dict_to_arr: (Dictionary<T, U>, type A?) -> Array<A<T, U>>
## where A: default extends AbstractKVPair, extends AbstractKVPair
##
## arr_to_dict: (Array<A<T, U>>) -> Dictionary<T, U>
## where A: extends AbstractKVPair
##
## transpose_to_kv(Array<T or U>, type A?) -> A<T, U>
## where A: default extends AbstractKVPair, extends AbstractKVPair
##
## transpose_from_kv(A<T, U>) -> Array<T or U>
## where A: extends AbstractKVPair
## 