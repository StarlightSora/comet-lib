## !! THIS CLASS MUST BE REGISTERED AS A SINGLETON !!
##
## Project > Project Settings > Globals > Select Script/Scele > Navigate to comet-lib/src/comet_singleton.gd
## Then move the autoload to the top of the list.
extends Node

## Dictionary<String, Any>
static var _g: Dictionary[String, Variant]

## static (String) -> OptionalType<Any>
##
## Read from the global space registry.
static func g(entry: String) -> OptionalType:
    return OptionalType.new(_g.get(entry))

## static (String) -> void
##
## Write to the global space registry.
static func mut_g(entry: String, value: Variant) -> void:
    _g.set(entry, value)

## static (String) -> OptionalType<Any>
##
## Write to the global space registry. The old value will be returned in an OptionalType.
static func mut_g_returning(entry: String, value: Variant) -> OptionalType:
    var temp := OptionalType.new(_g.get(entry))
    _g.set(entry, value)
    return temp

## async (float, bool?) -> void
func wait(how_long: float, in_physics_process: bool = false) -> void:
    await get_tree().create_timer(how_long, true, in_physics_process).timeout

## async (float, bool?) => float
##
## Return value is the actual time spent yielding.
func wait_returning(how_long: float, in_physics_process: bool = false) -> float:
    var start: int = Time.get_ticks_usec()
    await get_tree().create_timer(how_long, true, in_physics_process).timeout
    return (Time.get_ticks_usec() - start) as float / 1000.0 / 1000.0

## async (float, bool?) -> void
##
## Ignores `Engine.time_scale`.
func wait_real(how_long: float, in_physics_process: bool = false) -> void:
    await get_tree().create_timer(how_long, true, in_physics_process, true).timeout

## async (float, bool?) => float
##
## Ignores `Engine.time_scale`.
## Return value is the actual time spent yielding.
func wait_real_returning(how_long: float, in_physics_process: bool = false) -> float:
    var start: int = Time.get_ticks_usec()
    await get_tree().create_timer(how_long, true, in_physics_process, true).timeout
    return (Time.get_ticks_usec() - start) as float / 1000.0 / 1000.0

