class_name CometLayeredAudioPlayer
extends Node

var _cached_children: Array[CometAudioInstCache] = []

## mut () -> void
func play_audio() -> void:
	var dead_entries: Array[CometAudioInstCache] = []
	var de_len: int = 0
	for c in _cached_children:
		var maybe_underlying := c.try_into()
		if maybe_underlying:
			c.play_audio()
		else:
			dead_entries.push_back(c)
			de_len += 1
	while de_len > 0:
		de_len -= 1
		var next: CometAudioInstCache = dead_entries.pop_back()
		var pos := _cached_children.find(next)
		if not pos:
			push_warning("Could not find ", next.to_string(), " in cached_children")
			continue
		_cached_children.remove_at(pos)

## mut (T) -> bool
## where T: extends CometAudioStreamPlayer or CometAudioStreamPlayer2D or CometAudioStreamPlayer3D
## or AudioStreamPlayer or AudioStreamPlayer2D or AudioStreamPlayer3D
func register(node: Node) -> bool:
	if is_registered(node):
		return false
	var a := CometAudioInstCache.make(node)
	if a:
		_cached_children.push_back(a)
		return true
	else: return false

## mut (T) -> bool
## where T: extends CometAudioStreamPlayer or CometAudioStreamPlayer2D or CometAudioStreamPlayer3D
## or AudioStreamPlayer or AudioStreamPlayer2D or AudioStreamPlayer3D
func unregister(node: Node) -> bool:
	var u := _cached_children.find(node)
	if u:
		_cached_children.remove_at(u)
		return true
	else: return false

## (T) -> bool
## where T: extends CometAudioStreamPlayer or CometAudioStreamPlayer2D or CometAudioStreamPlayer3D
## or AudioStreamPlayer or AudioStreamPlayer2D or AudioStreamPlayer3D
func is_registered(node: Node) -> bool:
	var a = _cached_children.find(node)
	if a >= 0:
		return true
	else: return false

func _ready() -> void:
	for c in get_children():
		register(c)
	
