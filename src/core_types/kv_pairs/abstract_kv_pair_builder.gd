@abstract class_name AbstractKVPairBuilder
extends Resource

## Contracts:
##
## _init: () -> A<T, U>
## where A: extends AbstractKVPairBuilder
##
## dict_to_arr: (Dictionary<T, U>, type A?) -> Array<A<T, U>>
## where A: default extends AbstractKVPair, extends AbstractKVPair
##
## arr_to_dict: (Array<A<T, U>>) -> Dictionary<T, U>
## where A: extends AbstractKVPair