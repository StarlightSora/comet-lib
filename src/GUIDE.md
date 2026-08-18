# Function Signatures

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
- **No type safety for union types.** Example: A function that either takes a `float` or `int` and returns `float` has to be written as `func(in: Variant) -> float`, erasing the type information of `float || int`.
- **No type safety for nested type definitions.** Example: `Array[Dictionary[String, Variant]]` is invalid syntax, and has to be written as `Array[Dictionary]` instead, erasing the compile-time type information of the `Dictionary`'s keys and values.
- **No type safety for callables.** Example: A function that takes a callable {which takes `void` and returns `float`}, and returns `float`, has to be written as `func(f: Callable) -> float`, erasing the compile-time function signature information of `Callable`, and raising ambiguity about what the `Callable` should take and return.

#### What About Owned Values vs References?

**TL;DR: Worry about it the same way as you would do in contemporary GDScript.**

GDScript uses reference counting for automatic memory management. Because of this, the usual rules of ownership semantics from Rust does not apply here.

In addition, primitive types get passed by value (by implicit copies), while others typically get passed by reference. This is determined at runtime for generics (which are actually just `Variant`s).

Therefore, **references will not be marked in function signatures** due to it being practically impossible to denote. You need to be aware of whether your concrete types gets passed by value or reference.

#### What About Mutability vs Immutability?

**TL;DR: It won't be specified in the function signature, but will typically be documented seperately.**

Due to the above reason, it's hard to rigidly keep track of what's really mutable, immutable, will mutate or will not mutate. Even if a function doesn't mutate a parameter, or a method doesn't mutate the state of the associated instance, multiple variables may hold a reference to them, so mutation could happen anywhere for things that get passed by reference.

Therefore, **mutability will not be marked in function signatures**, but any functions that mutate something will be **documented** as such **seperately**.

#### Why Not Just Use Rust, C# or C++ Instead?

You absolutely could if you want true type safety, but these languages have a steeper learning curve than GDScript, is less tightly integrated with Godot, and is less dynamic.

## Generic Types

#### Unbound Generics

Generic types are typically denoted as `T`, `U`, `E`, `F` ... and do not exist as a concrete time in Godot. Whatever you pass becomes the concrete type in runtime.

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

- After the `where` keyword is where the binding starts.
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

Union types are denoted as `Type1 or Type2 or ...` where each `Type` is a concrete type or a bound generic type.

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
func option_in_result(a: OptionalType, b: Variant, ok: bool):
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
## (Func(int) -> int) -> int
func execute_with(f: Callable, value: int) -> int:
    return f.call(value)

var lambda := func(i: int) -> int:
    return i + 42

print(str(execute_with(lambda, 1))) # "43"
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