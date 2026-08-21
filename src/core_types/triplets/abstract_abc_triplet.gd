## Stores three values. The types can be different.
##
## This is the preferred way to return three values from a function, rather than using ad-hoc arrays or dictionaries.
@abstract class_name AbstractABCTriplet
extends Resource

## Contracts:
##
## _init: (T, U, V) -> A<T, U, V>
## where A: extends AbstractABCTriplet
##
## a: () -> T
##
## b: () -> U
##
## c: () -> V
##
## mut_a: mut (T) -> T
##
## mut_b: mut (U) -> U
##
## mut_c: mut (V) -> V
##