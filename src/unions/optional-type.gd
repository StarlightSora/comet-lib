class_name OptionalType
extends Resource

var _held: Variant
var _exists: bool

## Func(T) -> OptionalType<T>
func _init(content: Variant) -> void:
    _held = content
    _exists = content != null

## Func() -> bool
func is_some() -> bool:
    return _exists

## Func(Func(T) -> bool) -> bool
func is_some_and(callable: Callable) -> bool:
    if _exists:
        return callable.call(_held) as bool
    else:
        return false

## Func() -> bool
func is_none() -> bool:
    return not _exists

## Func(Func(T) -> bool) -> bool
func is_none_or(callable: Callable) -> bool:
    if _exists:
        return callable.call(_held) as bool
    else:
        return true

## Func(String) -> T
func expect(msg: String) -> Variant:
    if _exists:
        return _held
    else:
        push_error(msg)
        assert(false, msg)
        return _held

## Func() -> T
func unwrap() -> Variant:
    if _exists:
        return _held
    else:
        push_error("Cast failed!")
        assert(false, "Cast failed!")
        return _held

## Func(T) -> T
func unwrap_or(default: Variant) -> Variant:
    if _exists:
        return _held
    else:
        return default

## Func(Func() -> T) -> T
func unwrap_or_else(f: Callable) -> Variant:
    if _exists:
        return _held
    else:
        return f.call()

## Func(Func(T) -> U) -> OptionalType<U>
func map(f: Callable) -> OptionalType:
    if _exists:
        return f.call(_held)
    else:
        return self

## Func(Func(T) -> void) -> void
func inspect(f: Callable) -> void:
    if _exists:
        f.call(_held)

## Func(U, Func(T) -> U) -> U
func map_or(default: Variant, f: Callable) -> Variant:
    if _exists:
        return f.call(_held)
    else:
        return default

## Func(Func() -> U, Func(T) -> U) -> U
func map_or_else(d: Callable, f: Callable) -> Variant:
    if _exists:
        return f.call(_held)
    else:
        return d.call()

## Func(E) -> Result<T, E>
func ok_or(err: Variant) -> ResultType:
    if _exists:
        return ResultType.new(true, _held)
    else:
        return ResultType.new(false, err)

## Func(Func() -> E) -> Result<T, E>
func ok_or_else(e: Callable) -> ResultType:
    if _exists:
        return ResultType.new(true, _held)
    else:
        return ResultType.new(false, e.call())

## Func(OptionalType<U>) -> OptionalType<U>
func and_(optb: OptionalType) -> OptionalType:
    if _exists:
        return optb
    else:
        return self

## Func(Func(T) -> U) -> OptionalType<U>
func and_then(f: Callable) -> OptionalType:
    if _exists:
        return f.call(_held)
    else:
        return self

## Func(Func(T) -> bool) -> OptionalType<T>
func filter(predicate: Callable) -> OptionalType:
    if _exists:
        if predicate.call(_held):
            return self
        else:
            return OptionalType.new(null)
    else:
        return self

## Func(OptionalType<T>) -> OptionalType<T>
func or_(optb: OptionalType) -> OptionalType:
    if _exists:
        return self
    else:
        return optb

## Func(Func() -> OptionalType<T>) -> OptionalType<T>
func or_else(f: Callable) -> OptionalType:
    if _exists:
        return self
    else:
        return f.call()

## Func(OptionalType<T>) -> OptionalType<T>
func xor(optb: OptionalType) -> OptionalType:
    if _exists and not optb._exists:
        return self
    elif not _exists and optb._exists:
        return optb
    else:
        return OptionalType.new(null)

## Func(T) -> T
func insert(value: Variant) -> Variant:
    _exists = true
    _held = value
    return _held

## Func(T) -> T
func get_or_insert(value: Variant) -> Variant:
    if _exists:
        return _held
    else:
        _exists = true
        _held = value
        return _held

## Func(Func() -> T) -> T
func get_or_insert_with(f: Callable) -> Variant:
    if _exists:
        return _held
    else:
        _exists = true
        _held = f.call()
        return _held

## Func() -> OptionalType<T>
func take() -> OptionalType:
    if _exists:
        var temp = self.duplicate()
        _exists = false
        _held = null
        return temp
    else:
        return self

## Func(Func(T) -> bool) -> OptionalType<T>
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

## Func(T) -> OptionalType<T>
func replace(value: Variant) -> OptionalType:
    var temp = self.duplicate()
    _exists = true
    _held = value
    return temp

## Func() -> ResultType<OptionalType<T>, E>
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

## Func(DeepDuplicateMode) -> ResultType<OptionalType<T>, E>
## where T: impl duplicate_deep || impl Copy
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

## Func() -> OptionalType<T>
func flatten() -> OptionalType:
    if _exists:
        if _held is OptionalType:
            return _held
        else:
            return self
    else:
        return self