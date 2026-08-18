## A class used to represent success/error states in a type-safer and scaleable way.

class_name ResultType
extends Resource

@export var _held: Variant
@export var _ok: bool

## (bool?, T? or E?) -> ResultType<T, E>
func _init(is_okay: bool = false, content: Variant = null) -> void:
    _ok = is_okay
    _held = content

## () -> bool
func is_ok() -> bool:
    return _ok

## (Func(T) -> bool) -> bool
func is_ok_and(f: Callable) -> bool:
    if _ok:
        return f.call(_held) as bool
    else:
        return false

## () -> bool
func is_err() -> bool:
    return not _ok

## (Func(E) -> bool) -> bool
func is_err_and(f: Callable) -> bool:
    if _ok:
        return false
    else:
        return f.call(_held) as bool

## () -> OptionalType<T>
func ok() -> OptionalType:
    if _ok:
        return OptionalType.new(_held)
    else:
        return OptionalType.new(null)

## (DeepDuplicateMode) -> OptionalType<T>
## where T: impl duplicate_deep or impl Copy
func ok_as_dupe(deep_subresources_mode: DeepDuplicateMode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> OptionalType:
    if _ok:
        if _held.has_method("duplicate_deep"):
            return OptionalType.new(_held.duplicate_deep(deep_subresources_mode))
        else:
            return OptionalType.new(_held)
    else:
        return OptionalType.new(null)

## () -> new OptionalType<E>
func err() -> OptionalType:
    if _ok:
        return OptionalType.new(null)
    else:
        return OptionalType.new(_held)

## (DeepDuplicateMode) -> OptionalType<E>
## where E: impl duplicate_deep or impl Copy
func err_as_dupe(deep_subresources_mode: DeepDuplicateMode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> OptionalType:
    if _ok:
        return OptionalType.new(null)
    else:
        if _held.has_method("duplicate_deep"):
            return OptionalType.new(_held.duplicate_deep(deep_subresources_mode))
        else:
            return OptionalType.new(_held)

## (Func(T) -> U) -> ResultType<U, E>
func map(op: Callable) -> ResultType:
    if _ok:
        return ResultType.new(true, op.call(_held))
    else:
        return self

## (U, Func(T) -> U) -> U
func map_or(default: Variant, f: Callable) -> Variant:
    if _ok:
        return f.call(_held)
    else:
        return default

## (Func(E) -> U, Func(T) -> U) -> U
func map_or_else(d: Callable, f: Callable) -> Variant:
    if _ok:
        return f.call(_held)
    else:
        return d.call(_held)

## (Func(E) -> F) -> ResultType<T, F>
func map_err(op: Callable) -> ResultType:
    if _ok:
        return self
    else:
        return ResultType.new(false, op.call(_held))

## (Func(T) -> void) -> void
func inspect(f: Callable) -> void:
    if _ok:
        f.call(_held)

## (Func(E) -> void) -> void
func inspect_err(f: Callable) -> void:
    if not _ok:
        f.call(_held)

## canThrow (String) -> T
func expect(msg: String) -> Variant:
    if _ok:
        return _held
    else:
        push_error(msg)
        assert(false, msg)
        return _held

## canThrow () -> T
func unwrap() -> Variant:
    if _ok:
        return _held
    else:
        push_error("Cast failed!")
        assert(false, "Cast failed!")
        return _held

## canThrow (String) -> E
func expect_err(msg: String) -> Variant:
    if _ok:
        push_error(msg)
        assert(false, msg)
        return _held
    else:
        return _held

## canThrow () -> E
func unwrap_err() -> Variant:
    if _ok:
        push_error("Cast failed!")
        assert(false, "Cast failed!")
        return _held
    else:
        return _held

## (ResultType<U, E>) -> ResultType<U, E>
func and_(res: ResultType) -> ResultType:
    if _ok:
        return res
    else:
        return self

## (Func(T) -> ResultType<U, E>) -> ResultType<U, E>
func and_then(op: Callable) -> ResultType:
    if _ok:
        return op.call(_held)
    else:
        return self

## (ResultType<T, F>) -> ResultType<T, F>
func or_(res: ResultType) -> ResultType:
    if _ok:
        return self
    else:
        return res

## (Func(E) -> ResultType<T, F>) -> ResultType<T, F>
func or_else(op: Callable) -> ResultType:
    if _ok:
        return self
    else:
        return op.call(_held)

## (T) -> T
func unwrap_or(default: Variant) -> Variant:
    if _ok:
        return self._held
    else:
        return default

## (Func(E) -> T) -> T
func unwrap_or_else(op: Callable) -> Variant:
    if _ok:
        return self._held
    else:
        return op.call(_held)

## () -> OptionalType<ResultType<T, E>>
func transpose() -> OptionalType:
    if _ok and _held == null:
        return OptionalType.new(null)
    else:
        return OptionalType.new(self)

## (DeepDuplicateMode) -> OptionalType<ResultType<T, E>>
func transpose_as_dupe(deep_subresources_mode: DeepDuplicateMode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> OptionalType:
    if _ok and _held == null:
        return OptionalType.new(null)
    else:
        return OptionalType.new(self.duplicate_deep(deep_subresources_mode))

## () -> ResultType<T, E>
func flatten() -> ResultType:
    if _ok:
        if _held is ResultType:
            return _held
        else:
            return self
    else:
        return self

## () -> T? or E?
func to_raw_nullable_union() -> Variant:
    return _held