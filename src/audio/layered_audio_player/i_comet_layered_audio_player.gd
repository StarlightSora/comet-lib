class_name ICometLayeredAudioPlayer
extends RefCounted

## static (mut Array<CometAudioInstCache>) -> void
static func play_audio(cached_children: Array[CometAudioInstCache]) -> void:
	var dead_entries: Array[CometAudioInstCache] = []
	var de_len: int = 0
	for c in cached_children:
		var maybe_underlying := c.try_into()
		if maybe_underlying:
			c.play_audio()
		else:
			dead_entries.push_back(c)
			de_len += 1
	while de_len > 0:
		de_len -= 1
		var next: CometAudioInstCache = dead_entries.pop_back()
		var pos := cached_children.find(next)
		if not pos:
			push_warning("Could not find ", next.to_string(), " in cached_children")
			continue
		cached_children.remove_at(pos)

## static (mut Array<CometAudioInstCache>, CometAudioPlayable) -> bool
static func register(cached_children: Array[CometAudioInstCache], node: Node) -> bool:
	if is_registered(cached_children, node):
		return false
	var a := CometAudioInstCache.make(node)
	if a:
		cached_children.push_back(a)
		return true
	else: return false

## static (mut Array<CometAudioInstCache>, CometAudioPlayable) -> bool
static func unregister(cached_children: Array[CometAudioInstCache], node: Node) -> bool:
	var u := cached_children.find(node)
	if u:
		cached_children.remove_at(u)
		return true
	else: return false

## static (Array<CometAudioInstCache>, CometAudioPlayable) -> bool
static func is_registered(cached_children: Array[CometAudioInstCache], node: Node) -> bool:
	var a = cached_children.find(node)
	if a >= 0:
		return true
	else: return false

#func _ready() -> void:
	#for c in get_children():
		#register(c)
