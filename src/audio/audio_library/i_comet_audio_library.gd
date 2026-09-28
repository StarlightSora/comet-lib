class_name ICometAudioLibrary
extends RefCounted

## static (mut Dictionary<String, CometAudioInstCache>, String) -> void
static func play_audio(cached_children: Dictionary[String, CometLayeredAudioInstCache], key_name: String) -> bool:
	if is_registered(cached_children, null, key_name):
		var inner := cached_children[key_name].try_into()
		if inner:
			inner.play_audio()
			return true
		else:
			# probably expired from being destroyed
			unregister(cached_children, null, key_name)
			return false
	else:
		return false

## static (mut Dictionary<String, CometAudioInstCache>, CometAudioLayered, String?) -> bool
static func register(
	cached_children: Dictionary[String, CometLayeredAudioInstCache],
	node: Node, key_name: String = ""
) -> bool:
	var k: String = key_name if key_name else (node.name as String)
	if cached_children.has(k):
		return false
	else:
		var a := CometLayeredAudioInstCache.make(node)
		if a:
			cached_children.set(k, a)
			return true
		else:
			return false

## static (mut Dictionary<String, CometAudioInstCache>, CometAudioLayered?, String?) -> bool
static func unregister(
	cached_children: Dictionary[String, CometLayeredAudioInstCache],
	node: Node, key_name: String = ""
) -> bool:
	var k: String = key_name if key_name else (node.name as String)
	if cached_children.has(k):
		cached_children.erase(k)
		return true
	else:
		return false

## static (Dictionary<String, CometAudioInstCache>, CometAudioLayered?, String?) -> bool
static func is_registered(
	cached_children: Dictionary[String, CometLayeredAudioInstCache],
	node: Node, key_name: String = ""
) -> bool:
	return cached_children.has(key_name if key_name else (node.name as String))


#func _ready() -> void:
	#for c in get_children():
		#register(c)
