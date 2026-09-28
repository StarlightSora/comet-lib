## !! THIS CLASS MUST BE REGISTERED AS A SINGLETON !!
##
## Project > Project Settings > Globals > Select Script/Scele > Navigate to comet-lib/src/comet_singleton.gd
## Then move the autoload to the top of the list.
extends Node

## Dictionary<Any, Any>
static var _g: Dictionary[Variant, Variant]

## static (Any) -> OptionalType<Any>
##
## Read from the global space registry.
static func g(entry: Variant) -> OptionalType:
	return OptionalType.new(_g.get(entry))

## static (Any, Any) -> void
##
## Write to the global space registry.
static func mut_g(entry: Variant, value: Variant) -> void:
	_g.set(entry, value)

## static (Any, Any) -> OptionalType<Any>
##
## Write to the global space registry. The old value will be returned in an OptionalType.
static func mut_g_returning(entry: Variant, value: Variant) -> OptionalType:
	var temp := OptionalType.new(_g.get(entry))
	_g.set(entry, value)
	return temp

## async (float, bool?) -> void
##
## Use `await` on the call site.
func wait(how_long: float, in_physics_process: bool = false) -> void:
	await get_tree().create_timer(how_long, true, in_physics_process).timeout

## async (float, bool?) -> float
##
## Use `await` on the call site. Return value is the actual time spent yielding.
func wait_returning(how_long: float, in_physics_process: bool = false) -> float:
	var start: int = Time.get_ticks_usec()
	await get_tree().create_timer(how_long, true, in_physics_process).timeout
	return (Time.get_ticks_usec() - start) as float / 1000.0 / 1000.0

## async (float, bool?) -> void
##
## Use `await` on the call site. Ignores `Engine.time_scale`.
func wait_real(how_long: float, in_physics_process: bool = false) -> void:
	await get_tree().create_timer(how_long, true, in_physics_process, true).timeout

## async (float, bool?) -> float
##
## Use `await` on the call site. Ignores `Engine.time_scale`.
## Return value is the actual time spent yielding.
func wait_real_returning(how_long: float, in_physics_process: bool = false) -> float:
	var start: int = Time.get_ticks_usec()
	await get_tree().create_timer(how_long, true, in_physics_process, true).timeout
	return (Time.get_ticks_usec() - start) as float / 1000.0 / 1000.0

## static async (Func() -> Any?) -> Any?
##
## Calls a callable in async, letting downstream code keep executing (unless await is used at the call site).
## If the callable needs to accept arguments, they should be first bound via Callable.bindv. 
static func spawn(closure: Callable) -> Variant:
	return await closure.call()

func _process(delta: float) -> void:
	_elapsed_game_time += delta

func _physics_process(delta: float) -> void:
	_elapsed_physics_time += delta
