class_name ResultType
extends Resource

var _held: Variant
var _ok: bool

## Func(bool, T || E) -> ResultType<T, E>
func _init(is_okay: bool, content: Variant) -> void:
    _ok = is_okay
    _held = content

## Func() -> bool
func is_ok() -> bool:
    return _ok

## Func(Func(T) -> bool) -> bool
func is_ok_and(f: Callable) -> bool:
    if _ok:
        return f.call(_held) as bool
    else:
        return false

## Func() -> bool
func is_err() -> bool:
    return not _ok

## Func(Func(E) -> bool) -> bool
func is_err_and(f: Callable) -> bool:
    if _ok:
        return false
    else:
        return f.call(_held) as bool

## Func() -> OptionalType<T>
func ok() -> OptionalType:
    if _ok:
        return OptionalType.new(_held)
    else:
        return OptionalType.new(null)

## Func(DeepDuplicateMode) -> OptionalType<T>
## where T: impl duplicate_deep || impl Copy
func ok_as_dupe(deep_subresources_mode: DeepDuplicateMode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> OptionalType:
    if _ok:
        if _held.has_method("duplicate_deep"):
            return OptionalType.new(_held.duplicate_deep(deep_subresources_mode))
        else:
            return OptionalType.new(_held)
    else:
        return OptionalType.new(null)

## Func() -> new OptionalType<E>
func err() -> OptionalType:
    if _ok:
        return OptionalType.new(null)
    else:
        return OptionalType.new(_held)

## Func(DeepDuplicateMode) -> OptionalType<new E>
## where E: impl duplicate_deep || impl Copy
func err_as_dupe(deep_subresources_mode: DeepDuplicateMode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> OptionalType:
    if _ok:
        return OptionalType.new(null)
    else:
        if _held.has_method("duplicate_deep"):
            return OptionalType.new(_held.duplicate_deep(deep_subresources_mode))
        else:
            return OptionalType.new(_held)

## Func(Func(T) -> U) -> ResultType<U, E>
func map(op: Callable) -> ResultType:
    if _ok:
        return ResultType.new(true, op.call(_held))
    else:
        return self

## Func(U, Func(T) -> U) -> U
func map_or(default: Variant, f: Callable) -> Variant:
    if _ok:
        return f.call(_held)
    else:
        return default

## Func(Func(E) -> U, Func(T) -> U) -> U
func map_or_else(d: Callable, f: Callable) -> Variant:
    if _ok:
        return f.call(_held)
    else:
        return d.call(_held)

## Func(Func(E) -> F) -> ResultType<T, F>
func map_err(op: Callable) -> ResultType:
    if _ok:
        return self
    else:
        return ResultType.new(false, op.call(_held))

## Func(Func(T) -> void) -> void
func inspect(f: Callable) -> void:
    if _ok:
        f.call(_held)

## Func(Func(E) -> void) -> void
func inspect_err(f: Callable) -> void:
    if not _ok:
        f.call(_held)

## Func(String) -> T
func expect(msg: String) -> Variant:
    if _ok:
        return _held
    else:
        push_error(msg)
        assert(false, msg)
        return _held

## Func() -> T
func unwrap() -> Variant:
    if _ok:
        return _held
    else:
        push_error("Cast failed!")
        assert(false, "Cast failed!")
        return _held

## Func(String) -> E
func expect_err(msg: String) -> Variant:
    if _ok:
        push_error(msg)
        assert(false, msg)
        return _held
    else:
        return _held

## Func() -> E
func unwrap_err() -> Variant:
    if _ok:
        push_error("Cast failed!")
        assert(false, "Cast failed!")
        return _held
    else:
        return _held

## Func(ResultType<U, E>) -> ResultType<U, E>
func and_(res: ResultType) -> ResultType:
    if _ok:
        return res
    else:
        return self

## Func(Func(T) -> ResultType<U, E>) -> ResultType<U, E>
func and_then(op: Callable) -> ResultType:
    if _ok:
        return op.call(_held)
    else:
        return self

## Func(ResultType<T, F>) -> ResultType<T, F>
func or_(res: ResultType) -> ResultType:
    if _ok:
        return self
    else:
        return res

## Func(Func(E) -> ResultType<T, F>) -> ResultType<T, F>
func or_else(op: Callable) -> ResultType:
    if _ok:
        return self
    else:
        return op.call(_held)

## Func(T) -> T
func unwrap_or(default: Variant) -> Variant:
    if _ok:
        return self._held
    else:
        return default

## Func(Func(E) -> T) -> T
func unwrap_or_else(op: Callable) -> Variant:
    if _ok:
        return self._held
    else:
        return op.call(_held)

## Func() -> OptionalType<ResultType<T, E>>
func transpose() -> OptionalType:
    if _ok and _held == null:
        return OptionalType.new(ResultType.new(true, null))
    else:
        return OptionalType.new(self)

## Func(DeepDuplicateMode) -> OptionalType<ResultType<T, E>>
func transpose_as_dupe(deep_subresources_mode: DeepDuplicateMode = DeepDuplicateMode.DEEP_DUPLICATE_INTERNAL) -> OptionalType:
    if _ok and _held == null:
        return OptionalType.new(ResultType.new(true, null))
    else:
        return OptionalType.new(self.duplicate_deep(deep_subresources_mode))

## Func() -> ResultType<T, E>
func flatten() -> ResultType:
    if _ok:
        if _held is ResultType:
            return _held
        else:
            return self
    else:
        return self