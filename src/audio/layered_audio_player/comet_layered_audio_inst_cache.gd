class_name CometLayeredAudioInstCache
extends RefCounted

var _inst_weak: WeakRef = null

## async mut () -> bool
func play_audio() -> bool:
	var inst: Node = try_into()
	if not inst:
		return false
	inst.play_audio()
	return true

## () -> CometAudioLayered?
func try_into() -> Node:
	return _inst_weak.get_ref()

## static (CometAudioLayered) -> Self
static func make(from: Node) -> CometLayeredAudioInstCache:
	if (from is CometLayeredAudioPlayer) or (from is CometLayeredAudioPlayer2D) or (from is CometLayeredAudioPlayer3D):
		var a := CometLayeredAudioInstCache.new()
		a._inst_weak = weakref(from)
		return a
	else:
		push_warning(from.to_string(), " is not an CometAudioLibrary*!")
		return null
