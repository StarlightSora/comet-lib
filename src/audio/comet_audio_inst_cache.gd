class_name CometAudioInstCache
extends RefCounted

var _inst_weak: WeakRef = null
var _is_comet_audio: bool = false

## async mut () -> bool
func play_audio() -> bool:
	var inst: Node = try_into()
	if not inst:
		return false
	if _is_comet_audio:
		await CometSingleton.wait(inst.play_delay)
		inst.play(inst.play_from)
	else:
		inst.play()
	return true

## () -> T?
## where T: extends CometAudioStreamPlayer or CometAudioStreamPlayer2D or CometAudioStreamPlayer3D
## or AudioStreamPlayer or AudioStreamPlayer2D or AudioStreamPlayer3D
func try_into() -> Node:
	return _inst_weak.get_ref()

## static (T) -> Self
## where T: extends CometAudioStreamPlayer or CometAudioStreamPlayer2D or CometAudioStreamPlayer3D
## or AudioStreamPlayer or AudioStreamPlayer2D or AudioStreamPlayer3D
static func make(from: Node) -> CometAudioInstCache:
	if (from is AudioStreamPlayer) or (from is AudioStreamPlayer2D) or (from is AudioStreamPlayer3D):
		var a := CometAudioInstCache.new()
		a._inst_weak = weakref(from)
		return a
	else:
		push_warning(from.to_string(), " is not an AudioStreamPlayer*!")
		return null
