## Stores two values. The types can be different.
##
## This is the preferred way to return two values from a function, rather than using ad-hoc arrays or dictionaries.
@abstract class_name AbstractKVPair
extends Resource

## Contracts:
##
## _init: (T, U) -> A<T, U>
## where A: extends AbstractKVPair
##
## k: () -> T
##
## v: () -> U
##
## mut_k: mut (T) -> T
##
## mut_v: mut (U) -> U
##