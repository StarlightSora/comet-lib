# CometLib Function Signature Documentation Syntax

## General Syntax

```
(Type1, Type2, ...) -> ResultType
```

```
(Generic1, Generic2, ...) -> ResultType
where Generic1: [impl some_method and has some_property(SomeType)] or extends SomeClass ...,
where Generic2: impl some_method1 and impl some_method2 and ...,
...
```

## Why Document Function Signatures?

Why document function signatures if you can statically type them right in the function's declaration? Because of limitations of GDScript's type system.

In particular:

- **No type safety for generic types.** Example: A function that takes a generic type `T` and returns a generic type `T` has to be written as `func(in: Variant) -> Variant`, erasing the compile-time type information of `T`, and losing the guarantee that the function parameter and return value is the same type.
- **No type safety for union types.** Example: A function that either takes a `float` or `int` and returns `float` has to be written as `func(in: Variant) -> float`, erasing the type information of `float or int`.
- **No type safety for nested type definitions.** Example: `Array[Dictionary[String, Variant]]` is invalid syntax, and has to be written as `Array[Dictionary]` instead, erasing the compile-time type information of the `Dictionary`'s keys and values.
- **No type safety for callables.** Example: A function that takes a callable {which takes `void` and returns `float`}, and returns `float`, has to be written as `func(f: Callable) -> float`, erasing the compile-time function signature information of `Callable`, and raising ambiguity about what the `Callable` should take and return.
- **No explicit information about async/yielding functions.** Example: A function could use `await` in the body, but for the caller, it is hard to tell if it does or not.

The ultimate goal of the syntax is to improve type safety for developers without compromising on GDScript's dynamicness by addressing all of these issues in the documentation level.

CometLib's documentation follows this syntax. You are encouraged to follow this for your own projects as well.

#### What About Owned Values, References and Moves?

**TL;DR: Worry about it the same way as you would do in contemporary GDScript. And don't worry about moves.**

GDScript uses reference counting for automatic memory management. Because of this, the usual rules of ownership semantics from Rust does not apply here.

In addition, primitive types get passed by **value** (via implicit **copies**), while others typically get passed by **reference**. This is determined at runtime for generics (which are actually just `Variant`s).

Since complex types (`Object`s, `Array`, `Dictionary` etc) are almost always passed by reference, move semantics don't really apply, either. **Almost all functions will never consume its parameter(s)**. The ones that *do* will explicitly have to call `free` to consume the incoming reference, making any potential variables that held a reference to it to hold `null` instead. Such functions should be documented seperately about said behavior.

Therefore, **references** (`&`) **will not be marked in function signatures** due to it being practically impossible to denote. You need to be aware of whether your concrete types gets passed by value or reference.

Functions that explicitly return a deep-copied reference to a complex type (so that mutating it won't affect other existing references) will generally have the `_as_dup` suffix on its function name, or have it documented separately. **Most functions returning complex types return something containing existing references**, even if it is wrapped in a new type, so mutating the returned reference may cause unexpected behavior upstream. Use `Object.duplicate_deep` if you need a new reference of an existing complex type.

#### What About Mutability vs Immutability?

**TL;DR: It won't be specified in the function signature documentation, but will typically be documented seperately.**

Due to the above reason, it's hard to rigidly keep track of what's really mutable, immutable, will mutate or will not mutate. Even if a function doesn't mutate a parameter, or a method doesn't mutate the state of the associated instance, multiple variables may hold a reference to them, so mutation could happen anywhere for things that get passed by reference.

Therefore, **mutability will not be marked in function signatures**, but any functions that mutate something will be **documented** as such **seperately**.

#### Representation of Self

`self` **is not represented** in the function signature. It is completely redundant in a fully object-oriented language with poor support for mutability and ownership semantics.

#### Why Not Just Use Rust, C# or C++ Instead?

You absolutely could if you want true type safety, but these languages have a steeper learning curve than GDScript, is less tightly integrated with Godot, and is less dynamic.

#### Note: Classes vs Types

Because GDScript is a fully object-oriented language, they are functionally identical. However, they carry different semantic weight depending on context.

- As a **class**, we focus on its definition: properties, methods and inheritance.
- As a **type**, we focus on its usage: annotations, runtime checks, and how values are passed around.

## Generic Types

#### Unbound Generics

Generic types are typically denoted as `T`, `U`, `E`, `F` ... and do not exist as a concrete type in Godot. Whatever you pass becomes the concrete type in runtime.

Since Godot does not support generic types, they are actually passed as `Variant`, but we specify generic types in function signature documentations for clarity.

```gd
## (T) -> T
func fn_1(t: Variant) -> Variant:
    return t

print(str(fn_1(12.34))) # "12.34"
print(str(fn_1("Hello CometLib!"))) # "Hello CometLib!"
```

#### Bound Generics

Generic types can be bound to certain restrictions. This is needed when the function needs a certain method or property on a type, or the type must extend a certain class, to execute properly. Bound generics are denoted as such:

`(T) -> T where T: impl method_1 and has property_1(TypeOfProperty) and extends Class1 and ...`

- After the `where T:` is where the binding starts for `T`.
- `impl method_1` means `T` must have a method called `method_1`.
- `has property_1(TypeOfProperty)` means `T` must have a property called `property_1`, and its type is `TypeOfProperty`.
- `extends Class1` means `T` must extend (inherit from) `Class1`.

*Special case: `impl Copy` is the behavioral representation of types that always pass by value.*

The expression is evaluatated from left to right, one by one, by default. Use square brackets `[]` to further specify order of operations:

`(T) -> T where T: [impl method_1 and has property_1(TypeOfProperty)] or extends Class1 or [extends Class2 or impl method_2] ...`

```gd
## (T) -> void
## where T: [impl quack and has id(String)] or extends Bird
func do_quack(duck: Variant) -> void:
    if duck.has_method("quack"):
        if "id" in duck:
            print("duck's id: " + id)
            duck.quack()
            return
    if duck is Bird:
        duck.say() # Assuming the class Bird implements a method called say
        return
    push_error("Cast failed!")
    assert(false, "Cast failed!")

class_name Duck
extends Resource
var id = "asdf"
func quack() -> void:
    print("Quack!")

do_quack(Duck.new()) # "duck's id: asdf\nQuack!"
```

## Union Types

Union types are denoted as `Type1 or Type2 or ...` where each `Type` is a concrete type or a generic type.

Since Godot does not support union types, they are actually passed as `Variant`, but we specify them in documentation for clarity.

```gd
## (int or float) -> int
func fn_1(t: Variant) -> int:
    if t is float:
        return t as int
    elif t is int:
        return t
    else:
        push_error("Cast failed!")
        assert(false, "Cast failed!")
        return t as int

print(str(fn_1(12.34))) # "12.34"
print(str(fn_1(5678))) # "5678"
```

If you need to enforce type identicality (i.e. a function accepts two int or floats, but both arguments must have the same type), use generic typing, specifically with the **"where-union pattern"**:

```gd
## (T, T) -> T
## where T: int or float
fn add_(lhs: Variant, rhs: Variant) -> Variant:
    return lhs + rhs

print(str(add_(11, 22))) # 33
print(str(add_(1.1, 2.2))) # 3.3
```

If you need to implement bounds as well, use a comma after declaring the union type in the `where` clause, then declare the bounds:
```gd
# Assume that `Add` is implementation of being able to use the + operator
## (T, T) -> T
## where T: int or float, impl Add
fn add_(lhs: Variant, rhs: Variant) -> Variant:
    return lhs + rhs

print(str(add_(11, 22))) # 33
print(str(add_(1.1, 2.2))) # 3.3
```

## Types Holding Types / Nested Types

These are denoted as such: `OuterType<InnerType1, InnerType2, ...>`

Due to Godot's type system limitations, they are actually passed as `OuterType` but we specify them in documentation for clarity.

```gd
## (T, T, T) -> Array<T>
func make_array(a: Variant, b: Variant, c: Variant) -> Array[Variant]:
    var arr: Array[Variant] = []
    arr.push_back(a)
    arr.push_back(b)
    arr.push_back(c)
    return arr

print(str(make_array("x", "y", "z")[1])) # "y"

## (OptionalType<T>, E, bool) -> ResultType<OptionalType<T>, E>
func option_in_result(a: OptionalType, b: Variant, ok: bool) -> ResultType:
    if ok:
        return ResultType.new(true, a)
    else:
        return ResultType.new(false, b)

print(option_in_result(OptionalType.new("asdf"), 1234, true).unwrap().unwrap()) # "asdf"
print(str(option_in_result(OptionalType.new("asdf"), 1234, false).unwrap_err())) # "1234"
```

## Callables

Callables are denoted as such: `Func(Type1, Type2, ...) -> ReturnType`

or if bindings are needed:
```
Func(Generic1, Generic2, Generic3, ...) -> ReturnType
where Generic1: impl some_method and impl some_other_method and ...
where Generic2: has some_property(SomeType) and ...
where Generic3: extends SomeClass ...
...
```

They are simply passed as `Callable` but we specify them in documentation for clarity.

```gd
## (Func(int) -> int, int) -> int
func execute_with(f: Callable, value: int) -> int:
    return f.call(value)

var lambda := func(i: int) -> int:
    return i + 42

print(str(execute_with(lambda, 1))) # "43"
```

## Aliases

Complex type definitions can get long. This is when type aliases are convenient.

We use the `TYPEALIAS` keyword, then the alias name, then the actual type definition to do this: `TYPEALIAS AliasName: SomeGeneric or SomethingElse ... where SomeType: impl some_method ...`, then we use `AliasName` elsewhere whenever we need to mention the alias.

Bounds can be aliased as well. We use the `BINDALIAS` keyword, then the alias name, then the actual binding definition to do this: `BINDALIAS BindingName: impl some_method and has some_value(SomeType) and extends SomeClass and ...`, then we use `BindingName` elsewhere whenever we need to mention the alias.

- A `TYPEALIAS` can mention other `TYPEALIAS` and `BINDALIAS`-defined aliases.
- A `BINDALIAS` can mention other `BINDALIAS`-defined aliases.

Whenever you need to look up a definition of an alias, you can use `CTRL + SHIFT + F` (find all within project) and look for `TYPEALIAS YourAliasName:` or `BINDALIAS YourBindingName:`, and you should be able to locate it.

For `TYPEALIAS`es containing union types, type identicality is not enforced by default when mentioned elsewhere:

```
## TYPEALIAS SomeUnion: Type1 or Type2

## (SomeUnion, SomeUnion) -> bool
func some_func(a: Variant, b: Variant) -> bool
    return ...

# Note: Could also be written as:
# (Type1 or Type2, Type1 or Type2) -> bool

# or as:
# (T, U) -> bool where T: SomeUnion where U: SomeUnion

some_func(of_type_1, of_type_1) # This is OK
some_func(of_type_1, of_type_2) # This is also OK
```

To enforce type identicality, use the "where-union pattern":

```gd
## TYPEALIAS SomeUnion: Type1 or Type2

## (T, T) -> bool
## where T: SomeUnion
func some_func(a: Variant, b: Variant) -> bool
    return ...

some_func(of_type_1, of_type_1) # This is OK
some_func(of_type_1, of_type_2) # This is *NOT* OK
```

A drawback of aliases is that they add another layer of indirection that the IDE cannot automatically resolve. Best practice is to use aliases only for very complex types, or types that are used often. The below example likely does not require aliases, but is used here for demonstration.

```gd
## BINDALIAS QuackBinding: impl quack and has id
## TYPEALIAS NumberType: int or float
## TYPEALIAS MyDuck: T
## where T: QuackBinding or extends Bird

# We use the "where-union pattern" to enforce that lhs and rhs to be the same type.
# If we simply declared it as (NumberType, NumberType) -> bool, then type identicality is not enforced.
## (T, T) -> bool
## where T: NumberType
fn comp(lhs: Variant, rhs: Variant) -> bool:
    if lhs > rhs:
        return true
    else:
        return false

print(str(comp(12, 34))) # "false"
print(str(comp(56.78, 12.34))) # "true"

## (MyDuck) -> void
fn try_quack(probably_duck: Variant) -> void:
    if probably_duck.has_method("quack"):
        if "id" in probably_duck:
            print(id + " goes...")
            probably_duck.quack()
            return
    if probably_duck is Bird:
        probably_duck.say() # Assuming Bird class has a method called say
    push_error("Cast failed!")
    assert(false, "Cast failed!")

class_name Duck
extends Resource
var id = "asdf"
func quack() -> void:
    print("Quack!")

try_quack(Duck.new()) # "asdf goes...\nQuack!"
```

The function signatures of the above example could be written as such, without aliases:

```gd
## (T, T) -> bool
## where T: int or float
fn comp(lhs: Variant, rhs: Variant) -> bool

## (T) -> void
## where T: [impl quack and has id] or extends Bird
fn try_quack(probably_duck: Variant) -> void
```

## Async / Yielding Functions

If a function uses `await` in its body, the function signature must be prepended with `async`: `async (Type1, Type2, ...) -> ReturnType`

```gd
## async (float) -> String
func sleep_and_print(how_long: float) -> String:
    print("Going to sleep!")
    await get_tree().create_timer(how_long).timeout
    print("I woke up!")
    return "End"

print("Start")
print(await sleep_and_print(2.0))
```

## Nullables / `null`

The library prefers to use `OptionalType<T>` to represent nullables instead, to make nullability explicit. However, if representation of a value possibly being `null` directly is required (Godot-native representation), we use the `?` suffix, as such: `SomeType?`

This is necessary when interfacing with some native Godot APIs, other libraries, or writing extremely performance-critical/memory-heavy code.

```gd
# Preferred representation
var maybe_int: OptionalType = OptionalType.new(42) ## OptionalType<int>

# Godot-native representation
var maybe_int: int = 42 ## int?
```

## Error Handling

The library prefers to use `ResultType<T, E>` to represent success/fail states, instead of using nullables, union types or throwing if possible. `T` is the type of the success value, which is some appropriate type in the given context, and `E` is the type the failure value, which is typically a `String` or `Enum`. Refer to `core_types/result_type.gd` for more information. If `E` is an `Enum`, a `const Array[String]` is usually present in the same class as well for reflection of the `Enum` value.

For cases that do not need to represent specific error reasons, `OptionalType<T>` is used instead. Refer to `core_types/optional_type.gd` for more information.

If a function does *need* to throw, it does so by using `push_error(reason)` then `assert(false, reason)`. Throwing is only done for unrecoverable error states. Note that `assert` is a no-op in release builds, and **may result in the function returning a different type than the function signature promised** instead of crashing the thread!

**Functions that can throw are prefixed with `canThrow`** as the prefix of the function signature. Functions that *technically* can throw, but should **never throw under function signature documentation semantics** do *not* use this prefix. For example, `OptionalType.unwrap` is prefixed with `canThrow`, because it will throw if it actually contained nothing, but a function taking `int or float` could technically throw if a `String` is passed (which is possible without a parser error since union types have to be passed as `Variant`), but it wouldn't be marked as `canThrow` because it would never throw if the function signature documentation is properly respected.

```gd
Enum MaybeNonZeroErr { UNKNOWN, DIV_ZERO }
const MAYBE_NON_ZERO_ERR_REFLECTION: Array[String] = ["Unknown", "Divide by zero"]
## (T, T) -> ResultType<T, E>
## where T: int or float
## where E: MaybeNonZeroErr
func safe_divide(lhs: Variant, rhs: Variant) -> ResultType:
    if rhs == 0.0:
        return ResultType.new(false, MaybeNonZeroErr.DIV_ZERO)
    return ResultType.new(true, lhs / rhs)

print(str(safe_divide(4, 2).unwrap())) # "2"
print(MAYBE_NON_ZERO_ERR_REFLECTION[safe_divide(3.14, 0.0).unwrap_err()]) # "Divide by 0"

## (T) -> OptionalType<T>
## where T: int or float
func maybe_non_zero(v: Variant) -> OptionalType:
    if v == 0:
        return OptionalType.new(null)
    else:
        return OptionalType.new(v)

print(str(maybe_non_zero(32).unwrap())) # "32"
print(str(maybe_non_zero(0.0).is_some())) # false

# Bad example for production, but provided for demonstration purposes
## canThrow (int or float) -> void
func throw_if_negative(v: Variant) -> void:
    if v < 0:
        push_error("Argument was negative!")
        assert(false, "Argument was negative!")

throw_if_negative(3.14) # No-op
throw_if_negative(-12) # CRASH: "Argument was negative!"
```

# More Examples

```gd
## (float) -> float
func fn_1(a: float) -> float:
    return a + 42.0

## (String, int) -> String
func fn_2(in: String, from: int) -> String:
    return in.substr(from)

## (T, bool) -> OptionalType<T>:
func fn_3(in: Variant, keep: bool) -> OptionalType:
    if keep:
        return OptionalType.new(in)
    else:
        return OptionalType.new(null)

## (T, Func(T) -> U) -> U
func fn_4(in: Variant, transf: Callable) -> Variant:
    return transf.call(in)

## (T) -> T
## where T: impl duplicate_deep or impl Copy
func fn_5(in: Variant) -> Variant:
    if in.has_method("duplicate_deep"):
        return OptionalType.new(in.duplicate_deep())
    else:
        return OptionalType.new(_held)
```

# Inspiration

The syntax is largely inspired from **Rust**, but tuned heavily to fit GDScript's strengths and needs.

Rust is a statically typed, multi-paradigm, systems programming language, while GDScript is a dynamically typed, fully object-oriented, domain-specific scripting language. Not everything from Rust translates over to GDScript one-to-one and vice versa, so adjustments and compromises had to be made.