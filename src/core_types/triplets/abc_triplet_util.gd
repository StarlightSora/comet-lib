## pureClass
class_name ABCTripletUtil
extends AbstractABCTripletUtil

## (Array<T or U or V>, type A?) -> A<T, U, V>
## where A: default ABCTriplet, extends AbstractABCTriplet
##
## Note: The 0th element of `arr` is `T`, the 1st element is `U`, the 2nd element is `V`. Any extra elements will be ignored.
static func transpose_to_abc(arr: Array[Variant], make_as: Object = ABCTriplet) -> AbstractABCTriplet:
    return make_as.new(arr[0], arr[1], arr[2])

## transpose_from_abc(A<T, U, V>) -> Array<T or U or V>
## where A: extends AbstractABCTriplet
##
## Note: The 0th element of the returning reference is `T`, the 1st element is `U`, the 2nd element is `V`.
static func transpose_from_abc(abc: AbstractABCTriplet) -> Array[Variant]:
    return [abc.a(), abc.b(), abc.c()]