## A class used to represent nullable values in a type-safer and scaleable way.

class_name OptionalType
extends Resource

@export var _held: Variant
@export var _exists: bool

## (T?) -> OptionalType<T>
func _init(content: Variant = null) -> void:
    _held = content
    _exists = content != null

## () -> bool
func is_some() -> bool:
    return _exists

## (Func(T) -> bool) -> bool
func is_some_and(callable: Callable) -> bool:
    if _exists:
        return callable.call(_held) as bool
    else:
        return false

## () -> bool
func is_none() -> bool:
    return not _exists

## (Func(T) -> bool) -> bool
func is_none_or(callable: Callable) -> bool:
    if _exists:
        return callable.call(_held) as bool
    else:
        return true

## canThrow (String) -> T
func expect(msg: String) -> Variant:
    if _exists:
        return _held
    else:
        push_error(msg)
        assert(false, msg)
        return _held

## canThrow () -> T
func unwrap() -> Variant:
    if _exists:
        return _held
    else:
        push_error("Cast failed!")
        assert(false, "Cast failed!")
        return _held

## (T) -> T
func unwrap_or(default: Variant) -> Variant:
    if _exists:
        return _held
    else:
        return default

## (Func() -> T) -> T
func unwrap_or_else(f: Callable) -> Variant:
    if _exists:
        return _held
    else:
        return f.call()

## (Func(T) -> U) -> OptionalType<U>
func map(f: Callable) -> OptionalType:
    if _exists:
        return f.call(_held)
    else:
        return self

## (Func(T) -> void) -> void
func inspect(f: Callable) -> void:
    if _exists:
        f.call(_held)

## (U, Func(T) -> U) -> U
func map_or(default: Variant, f: Callable) -> Variant:
    if _exists:
        return f.call(_held)
    else:
        return default

## (Func() -> U, Func(T) -> U) -> U
func map_or_else(d: Callable, f: Callable) -> Variant:
    if _exists:
        return f.call(_held)
    else:
        return d.call()

## (E) -> Result<T, E>
func ok_or(err: Variant) -> ResultType:
    if _exists:
        return ResultType.new(true, _held)
    else:
        return ResultType.new(false, err)

## (Func() -> E) -> Result<T, E>
func ok_or_else(e: Callable) -> ResultType:
    if _exists:
        return ResultType.new(true, _held)
    else:
        return ResultType.new(false, e.call())

## (OptionalType<U>) -> OptionalType<U>
func and_(optb: OptionalType) -> OptionalType:
    if _exists:
        return optb
    else:
        return self

## (Func(T) -> U) -> OptionalType<U>
func and_then(f: Callable) -> OptionalType:
    if _exists:
        return f.call(_held)
    else:
        return self

## (Func(T) -> bool) -> OptionalType<T>
func filter(predicate: Callable) -> OptionalType:
    if _exists:
        if predicate.call(_held):
            return self
        else:
            return OptionalType.new(null)
    else:
        return self

## (OptionalType<T>) -> OptionalType<T>
func or_(optb: OptionalType) -> OptionalType:
    if _exists:
        return self
    else:
        return optb

## (Func() -> OptionalType<T>) -> OptionalType<T>
func or_else(f: Callable) -> OptionalType:
    if _exists:
        return self
    else:
        return f.call()

## (OptionalType<T>) -> OptionalType<T>
func xor(optb: OptionalType) -> OptionalType:
    if _exists and not optb._exists:
        return self
    elif not _exists and optb._exists:
        return optb
    else:
        return OptionalType.new(null)

## (T) -> T
func insert(value: Variant) -> Variant:
    _exists = true
    _held = value
    return _held

## (T) -> T
func get_or_insert(value: Variant) -> Variant:
    if _exists:
        return _held
    else:
        _exists = true
        _held = value
        return _held

## (Func() -> T) -> T
func get_or_insert_with(f: Callable) -> Variant:
    if _exists:
        return _held
    else:
        _exists = true
        _held = f.call()
        return _held

## () -> OptionalType<T>
func take() -> OptionalType:
    if _exists:
        var temp = self.duplicate()
        _exists = false
        _held = null
        return temp
    else:
        return self

## (Func(T) -> bool) -> OptionalType<T>
func take_if(predicate: Callable) -> OptionalType:
    if _exists:
        if predicate.call(_held):
            var temp = self.duplicate()
            _exists = false
            _held = null
            return temp
        else:
            return OptionalType.new(null)
    else:
        return self

## (T) -> OptionalType<T>
func replace(value: Variant) -> OptionalType:
    var temp = self.duplicate()
    _exists = true
    _held = value
    return temp

## () -> ResultType<OptionalType<T>, E>
func transpose() -> ResultType:
    if _exists:
        if _held is ResultType:
            if _held._ok:
                return ResultType.new(true, OptionalType.new(_held._held))
            else:
                return ResultType.new(false, _held._held)
        else:
            push_error("Cast failed!")
            assert(false, "Cast failed!")
            return ResultType.new(true, OptionalType.new(null))
    else:
        return ResultType.new(true, OptionalType.new(null))

## (DeepDuplicateMode) -> ResultType<OptionalType<T>, E>
## where T: impl duplicate_deep or impl Copy
func transpose_as_dupe(deep_subresources_mode: DeepDuplicateMode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> ResultType:
    if _exists:
        if _held is ResultType:
            if _held._ok:
                if _held._held.has_method("duplicate_deep"):
                    return ResultType.new(true, OptionalType.new(_held._held.duplicate_deep(deep_subresources_mode)))
                else:
                    return ResultType.new(true, OptionalType.new(_held._held))
            else:
                return ResultType.new(false, _held._held)
        else:
            push_error("Cast failed!")
            assert(false, "Cast failed!")
            return ResultType.new(true, OptionalType.new(null))
    else:
        return ResultType.new(true, OptionalType.new(null))

## () -> OptionalType<T>
func flatten() -> OptionalType:
    if _exists:
        if _held is OptionalType:
            return _held
        else:
            return self
    else:
        return self

## () -> T?
func to_raw_nullable() -> Variant:
    return _held