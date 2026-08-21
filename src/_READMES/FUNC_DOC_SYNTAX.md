# CometLib Function Signature Documentation Syntax

## General Syntax

```
prefixes (Type1, Type2, ...) -> ResultType
```

```
prefixes (Generic1, Generic2, ...) -> ResultType
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

## Compared to Rust

### What About Owned Values, References and Moves?

**TL;DR: Worry about it the same way as you would do in contemporary GDScript. And don't worry about moves.**

GDScript uses reference counting for automatic memory management. Because of this, the usual rules of ownership semantics from Rust does not apply here.

In addition, primitive types get passed by **value** (via implicit **copies**), while others typically get passed by **reference**. This is determined at runtime for generics (which are actually just `Variant`s).

Since complex types (`Object`s, `Array`, `Dictionary` etc) are almost always passed by reference, move semantics don't really apply, either. **Almost all functions will never consume its parameter(s)**. The ones that *do* will explicitly have to call `free` to consume the incoming reference, making any potential variables that held a reference to it to hold `null` instead. Such functions should be documented seperately about said behavior.

Therefore, **references** (`&`) **will not be marked in function signatures** due to it being practically impossible to denote. You need to be aware of whether your concrete types gets passed by value or reference.

Functions that explicitly return a deep-copied reference to a complex type (so that mutating it won't affect other existing references) will generally have the `_as_dup` suffix on its function name, or have it documented separately. **Most functions returning complex types return something containing existing references**, even if it is wrapped in a new type, so mutating the returned reference may cause unexpected behavior upstream. Use `Object.duplicate_deep` if you need a new reference of an existing complex type.

### What About Mutability?

**TL;DR: It is only documented in function parameters and as a prefix to the function itself with the `mut` annotation, but omitted in return values and local variables.**

Almost every complex type is mutable (can be modified) in GDScript, and in a language like GDScript, mutation (the act of modifying) is very common. Therefore, it is typically redundant to annotate something as mutable (or immutable) in the context of return values and local variables.

However, it is still very helpful to annotate if a certain function would mutate its parameter(s), or `self` (the class instance itself). Therefore, **we use the `mut` keyword to denote mutability in function parameters and function prefixes**, as such:

- Functions mutating `self`: `mut (Type1, Type2, ...) -> ReturnType`
- Functions mutating parameters: `(mut Type1, mut Type2, ...) -> ReturnType`
- Functions mutating both `self` and parameters: `mut (mut Type1, mut Type2, ...) -> ReturnType`

Note that `mut` means it *could* mutate or *is allowed to* mutate, not that it *must* or *always* mutate.

`mut` is never used for annotating primitive types that do an implicit copy when assigned to a new variable, in the context of annotating function parameters.

In the context of function prefixes and parameters, the ones not annotated as `mut` do not mutate the associated instance of the given type.

In contexts outside of this, we do not annotate with `mut` explicitly, and we default to the assumption that it is always `mut` unless documented otherwise.

```gdscript
class_name MyClass
extends Resource

var my_state: int = 0

## () -> int
func query() -> int:
    return my_state

## mut (int) -> int
func increment(by: int) -> int:
    my_state += by # `self` mutation happens here
    return my_state

## (mut MyClass) -> int
func write_into(other: MyClass) -> int:
    var temp := other.my_state
    other.my_state = my_state # parameter mutation happens here
    return temp
```

### Representation of Self

`self` **is not represented** in the function signature. It is completely redundant in a fully object-oriented language with poor support for mutability and ownership semantics.

### Why Not Just Use Rust, C# or C++ Instead?

You absolutely could if you want true type safety, but these languages have a steeper learning curve than GDScript, is less tightly integrated with Godot, and is less dynamic.

### Note: Classes vs Types

Because GDScript is a fully object-oriented language, they are functionally identical. However, they carry different semantic weight depending on context.

- As a **class**, we focus on its definition: properties, methods and inheritance.
- As a **type**, we focus on its usage: annotations, runtime checks, and how values are passed around.

## Generic Types

### Unbound Generics

Generic types are typically denoted as `T`, `U`, `E`, `F` ... and do not exist as a concrete type in Godot. Whatever you pass becomes the concrete type in runtime.

Since Godot does not support generic types, they are actually passed as `Variant`, but we specify generic types in function signature documentations for clarity.

```gdscript
## (T) -> T
func fn_1(t: Variant) -> Variant:
    return t

print(str(fn_1(12.34))) # "12.34"
print(str(fn_1("Hello CometLib!"))) # "Hello CometLib!"
```

### Bound Generics

Generic types can be bound to certain restrictions. This is needed when the function needs a certain method or property on a type, or the type must extend a certain class, to execute properly. Bound generics are denoted as such:

`(T) -> T where T: impl method_1 and has property_1(TypeOfProperty) and extends Class1 and ...`

- After the `where T:` is where the binding starts for `T`.
- `impl method_1` means `T` must have a method called `method_1`.
- `has property_1(TypeOfProperty)` means `T` must have a property called `property_1`, and its type is `TypeOfProperty`.
- `extends Class1` means `T` must extend (inherit from) `Class1`.

*Special case: `impl Copy` is the behavioral representation of types that always pass by value.*

The expression is evaluatated from left to right, one by one, by default. Use square brackets `[]` to further specify order of operations:

`(T) -> T where T: [impl method_1 and has property_1(TypeOfProperty)] or extends Class1 or [extends Class2 or impl method_2] ...`

```gdscript
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

```gdscript
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

```gdscript
## (T, T) -> T
## where T: int or float
fn add_(lhs: Variant, rhs: Variant) -> Variant:
    return lhs + rhs

print(str(add_(11, 22))) # 33
print(str(add_(1.1, 2.2))) # 3.3
```

If you need to implement bounds as well, use a comma after declaring the union type in the `where` clause, then declare the bounds:
```gdscript
# Assume that `Add` is implementation of being able to use the + operator
## (T, T) -> T
## where T: int or float, impl Add
fn add_(lhs: Variant, rhs: Variant) -> Variant:
    return lhs + rhs

print(str(add_(11, 22))) # 33
print(str(add_(1.1, 2.2))) # 3.3
```

## `not`

The `not` keyword can be used to negate a binding. For example:

```gdscript
## (T) -> void
## where T: not extends Node3D
func test1(incoming: Variant) -> void:
    pass

## (T) -> void
## where T: not OptionalType<U> and not bool
func test2(incoming: Variant) -> void:
    pass
```

## Types Holding Types / Nested Types

These are denoted as such: `OuterType<InnerType1, InnerType2, ...>`

Due to Godot's type system limitations, they are actually passed as `OuterType` but we specify them in documentation for clarity.

```gdscript
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

More generally, they are annotated the same way as a regular function would be, but with `Func` right before the opening paranthesis.

In particular, if prefixes and mutability needs to be annotated, we do it the same way as if we are annotating a regular function. For example, if a callable could throw, and can mutate a parameter:

`canThrow Func(mut Type1, Type2, Type3, ...) -> ReturnType` (More information about `canThrow` in the "Error Handling" section)

**IMPORTANT: The only exception is that if a callable can mutate something within the scope of where the callable was declared at, we do _not_ prefix the callable with `mut`.** This is because as the callee (AKA, as the one that declared the function), it is usually none of our business if something that is outside of the function and class' scope gets mutated or not, since we have no way of directly accessing exterior scope anyways.

```gdscript
# Callee script
# This `mut` prefix is redundant, because it's none of our business if `a` gets mutated or not, as it isn't in our scope
## (mut Func() -> void) -> void
func test(f: Callable) -> void
    f.call()

# Caller script
var a := SomeClass.new()
var lmb := func() -> void:
    a.mutate_self_somehow()

test(lmb)
```

Callables are simply passed as `Callable` but we specify the incoming and outgoing types in documentation for clarity.

```gdscript
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

```gdscript
## TYPEALIAS SomeUnion: Type1 or Type2

## (T, T) -> bool
## where T: SomeUnion
func some_func(a: Variant, b: Variant) -> bool
    return ...

some_func(of_type_1, of_type_1) # This is OK
some_func(of_type_1, of_type_2) # This is *NOT* OK
```

A drawback of aliases is that they add another layer of indirection that the IDE cannot automatically resolve. Best practice is to use aliases only for very complex types, or types that are used often. The below example likely does not require aliases, but is used here for demonstration.

```gdscript
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

```gdscript
## (T, T) -> bool
## where T: int or float
fn comp(lhs: Variant, rhs: Variant) -> bool

## (T) -> void
## where T: [impl quack and has id] or extends Bird
fn try_quack(probably_duck: Variant) -> void
```

## Async / Yielding Functions

If a function uses `await` in its body, the function signature must be prepended with `async`: `async (Type1, Type2, ...) -> ReturnType`

```gdscript
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

```gdscript
# Preferred representation
var maybe_int: OptionalType = OptionalType.new(42) ## OptionalType<int>

# Godot-native representation
var maybe_int: int = 42 ## int?
```

To convert `SomeType?` to `OptionalType<SomeType>`, construct an `OptionalType` as such: `OptionalType.new(value_of_some_type)`

## Error Handling

The library prefers to use `ResultType<T, E>` to represent success/fail states, instead of using nullables, union types or throwing if possible. `T` is the type of the success value, which is some appropriate type in the given context, and `E` is the type the failure value, which is typically a `String` or `Enum`. Refer to `core_types/result_type.gd` for more information on how to handle `ResultType`. If `E` is `Enum`, a `const Array<String>` is usually present in the same class as well for reflection of the `Enum` value.

For cases that do not need to represent specific error reasons, `OptionalType<T>` is used instead. Refer to `core_types/optional_type.gd` for more information on how to handle `OptionalType`.

If a function does *need* to throw, it does so by calling `push_error(reason)` then `assert(false, reason)`. Throwing is only done for unrecoverable error states. Note that `assert` is a no-op in release builds, and **may result in the function returning a different type than the function signature promised** instead of crashing the thread!

**Functions that can throw are prefixed with `canThrow`** as the prefix of the function signature. Functions that *technically* can throw, but should **never throw under function signature documentation semantics** do *not* use this prefix. For example, `OptionalType.unwrap` is prefixed with `canThrow`, because it will throw if it actually contained nothing, but a function taking `int or float` could technically throw if a `String` is passed (which is possible without a parser error since union types have to be passed as `Variant`), but it wouldn't be marked as `canThrow` because it would never throw if the function signature documentation is properly respected.

```gdscript
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

## Associated Types

Especially when working with interfaces and builder classes, we sometimes need to know what type to refer to as a template. We accept an associated type to do this. **Associated types are prefixed with `type`**. In addition, associated types can be nullable, but a default type must be specified if that is the case, with `default` as a bound generic type. You can do this as such:

`(type A?) -> AbstractTypeHolder<A> where A: default SomeConcreteType, extends AbstractType ...`

With a captured associated type, we can make instances with it:

```gdscript
## (type T?) -> T
## where T: default Resource, extends Object
func instantiate_associated_type(assoc_type: Object = Resource) -> Variant:
    return assoc_type.new()
```

Here, we ask for an associated type that extends `Object`. If it's not given, we assume it's `Resource`.

Note that the default associated type must not be an abstract type, or else your function may crash!

Associated types have to be captured as `Object` when writing the actual GDScript function declaration. Below is actual code from the CometLib library that uses associated types.

```gdscript
## (Dictionary<T, U>, type A?) -> Array<A<T, U>>
## where A: default KVPair, extends AbstractKVPair
func dict_to_arr(dict: Dictionary[Variant, Variant], make_as: Object = KVPair) -> Array[AbstractKVPair]:
    var arr: Array[AbstractKVPair] = []
    arr.resize(dict.size())
    var i: int = 0
    for key in dict:
        arr[i] = make_as.new(key, dict[key])
        i += 1
    return arr

## (Array<A<T, U>>) -> Dictionary<T, U>
## where A: extends AbstractKVPair
func arr_to_dict(arr: Array[AbstractKVPair]) -> Dictionary[Variant, Variant]:
    var dict: Dictionary[Variant, Variant] = { }
    for value in arr:
        dict.set(value.k(), value.v())
    return dict
```

### Interfaces With Associated Types

If you need an interface that needs associated types, use duck typing, and document contracts in the interface, as such:

```gdscript
@abstract class_name AbstractKVPair
extends Resource

## Contracts:
##
## _init: (T, U) -> A<T, U>
## where A: extends AbstractKVPair
##
## k: () -> T
##
# ...
# -- # -- # -- # -- # -- # -- # -- #
class_name KVPair
extends AbstractKVPair

@export var _key: Variant
@export var _value: Variant

# Note: We have `key` and `value` as `null` by default in the actual function declaration;
# this is due to a GDScript quirk with types that have `@export` properties.
# For our function signature documentation we don't mark them as nullable.
## (T, U) -> KVPair<T, U>
func _init(key: Variant = null, value: Variant = null) -> void:
    _key = key
    _value = value

## () -> T
func k() -> Variant:
    return _key
# ...
```

## Static Functions / `static`

*This section explains about `static` in more detail as well because the official Godot documentation around `static` is very sparse.*

**Static functions need to be annotated with `static` as a prefix** in the function signature, as such: `static (Type1, Type2, ...) -> ReturnType`

**This rule does not apply for functions in `pureClass` classes** (discussed below), as it would be redundant.

Static functions can be called directly without the need of an instance of the class. In the function body, they have no access to `self`; meaning they cannot call non-`static` member functions (methods) nor access non-`static` properties. This does *not* mean that all `static func`s are non-`mut`, as they can still mutate `static var`s.

Note: In a similar vein, `static var`s and `const`s can be accessed directly without the need of a class instance as well.

```gdscript
# Note: This class will not work as-is due to the parser errors below
class_name MyClass
extends Resource

static var my_static_property: float = 42.0
var my_property: float = 21.0

## static () -> void
static func static_example() -> void:
    print(str(my_static_property)) # OK
    print(str(my_property)) # PARSER ERROR

## () -> void
func nonstatic_example() -> void:
    print(str(my_static_property)) # OK
    print(str(my_property)) # OK

## static mut () -> void
static func static_mut_example() -> void:
    my_static_property += 1.0 # OK
    my_property += 1.0 # PARSER ERROR

## mut () -> void
func mut_example() -> void:
    my_static_property += 1.0 # OK
    my_property += 1.0 # OK
```

### Pure Classes

**Some classes are considered "pure"**, which means that they hold **no mutable state**, and all its methods produce **fully deterministic outputs** regardless of when and where it was called, as long as all the given arguments had the exact same states and values.

In other words, this means the class **only has `const`s, `enum`s, and non-`mut` `static func`s. `static var`s** with its names **prefixed with a `_`** *(GDScript convention to mark a class member as private)*, and has its **value preassigned** are also considered to obey this rule, **as long as it is never mutated** externally and internally.
 
*Note: `static` on `var`s make it so that the variable is shared across the class and all of its instances. `static` on `func`s make it so that the method belongs to the class itself, instead of instances of the class.*

For example, this means `static var _rng: RandomNumberGenerator = RandomNumberGenerator.new()` is *not* considered to obey this rule, as it self-mutates every time it is called to return a new random number. In fact, a function using this `_rng` would have to be marked as `mut`. In contrast, a method with the function signature `static (mut RandomNumberGenerator) -> float` *is* considered to obey this rule, because the output will always be the same as long as the incoming `RandomNumberGenerator` have the exact same state.

Note that **`static func`s can still access globals or other externally accessible state**, for example, the `Time` singleton and the scene tree. **If they access state that are nondeterministic immutably, then the function must be prefixed with `impure`**. This does not disqualify the entire class from being a `pureClass`, and this annotation is only needed for `pureClass` functions. The reason for such functions not disqualifying the entire class is for pragmatic reasons. If they **mutate** external state however, this disqualifies the entire function from being a `pureClass` as the function would be `mut`.

For example, if a `static func` references real-life time in the function body, then it needs to be marked as `impure`. If it accesses the scene tree (**Note: This is a hypothetical, `static func`s cannot access the scene tree!**), this is fine as long as the resulting behavior is guaranteed to be deterministic (i.e. creating an ad-hoc `Timer`* for the sake of yielding code execution). <sub>*see Technicalities section</sub>

**Pure classes are documented with `pureClass` on the top level documentation of the class.** Example:

```gdscript
## pureClass
class_name MyLib
extends RefCounted

enum NumberSign { NEGATIVE, ZERO, POSITIVE }
const MEANING_OF_LIFE: int = 42
# This callable essentially casts an `int` to an `enum`.
# Not recommended to liberally do in prod as it may create invalid `enum` values,
# but done here as an example.
# Note: Callables cannot be `const` in GDScript, so we assign them as `static var` instead.
static var _make_sign_enum: Callable = func(a: float) -> NumberSign: return (sign(a) + 1) as NumberSign

## (int) -> int
static func do_something(a: int) -> int:
    return a + MEANING_OF_LIFE

## (int) -> NumberSign
static func sign_enum(a: float) -> NumberSign:
    return _make_sign_enum.call(a)

## impure () -> float
static func get_time_passed_since_start() -> float:
    return Time.get_ticks_usec() as float / 1000.0 / 1000.0
```

**There is no need to instantiate a pure class.** You can call their methods, access any `static var`,s, `const`s, and `enum`s directly:

```gdscript
print(str(MyLib.do_something(-21))) # "21"
print(str(MyLib.sign_enum(42.0))) # "2" (Corresponds to `NumberSign.POSITIVE`, but `enum`s implicitly gets casted to `int`)
print(str(MyLib.MEANING_OF_LIFE)) # "42"
print(str(MyLib._make_sign_enum.call(-123.0))) # "0" (Bad practice as this is a private property, only done here as an example)
print(str(MyLib.get_time_passed_since_start())) # Output is nondeterminsitic
```

#### Technicalities

- A class with non-`static` `func`/`var`s are, by definition, still grounds for qualifying as a `pureClass` if the `func`s never mutate interior state and if the `var`s never get mutated. However, all `func`/`var`s must be `static` regardless so they can be accessed directly without the need of an instantiated class.
- `Timer`s and other similar `async` behavior that seem to be deterministic are actually inherently nondeterministic as their actual wall-clock time passed differs slightly every time. The technical reasons behind this is beyond the scope of this document. Regardless, we treat them as deterministic, by assuming ideal conditions.
- Writing on globally accessible state in a way that will not cause cascading side effects and will be fully reverted by the function is not considered to break the rule.
- If a class has a `static var` that *can* mutate, but if no mutation actually happens in runtime, and if the instance always gets created deterministically, then this is still considered to obey the rule.

## Recursive Generics / `Any` / `AnyFlat`

**`Any` is a union type of every type, including all `Array<T>`s and `Dictionary<U, V>`s**. It is identical to an unbound generic type, but without any type identicality enforcement. In GDScript this is equivalent to raw `Variant`. Note that `Any` is very useful when combined with `not`.

```gdscript
## (Any) -> void
func literally_anything(something: Variant) -> void:
    print(str(something))
```

Below is an example of expressing a **recursive generic type**. We define a base dictionary as `R`, with `String` keys, and `R or T` values. `T` can be anything as long as it's not a `Dictionary` (that isn't `R`) or an `Array`.

Note that `Any` is very useful in conjunction with `not`, as we usually do not care what types go inside a negated nested type.

```gdscript
## (R) -> void
## where R: Dictionary<String, R or T>
## where T: not Dictionary<Any, Any> and not Array<Any>
func recursive_dict(rdict: Dictionary[String, Variant]) -> void:
    for key in rdict:
        var value: Variant = rdict[value]
        if value is Dictionary:
            recursive_dict(value)
        else:
            print(str(value))

# The above signature could be written as, without Any:
## (R) -> void
## where R: Dictionary<String, R or T>
## where T: not Dictionary<U, V> and not Array<W>
```

This can be simplified with **`AnyFlat`** while not compromising in safety. This is a **union type of everything except `Array<T>` and `Dictionary<U, V>`**:

```gdscript
## (R) -> void
## where R: Dictionary<String, R or AnyFlat>
func recursive_dict(rdict: Dictionary[String, Variant]) -> void:
    for key in rdict:
        var value: Variant = rdict[value]
        if value is Dictionary:
            recursive_dict(value)
        else:
            print(str(value))
```

# More Examples (WIP)

```gdscript
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
        return OptionalType.new(in)
```

# Inspiration

The syntax is largely inspired from **Rust**, but tuned heavily to fit GDScript's strengths and needs.

Rust is a statically typed, multi-paradigm, systems programming language, while GDScript is a dynamically typed, fully object-oriented, domain-specific scripting language. Not everything from Rust translates over to GDScript one-to-one and vice versa, so adjustments and compromises had to be made.