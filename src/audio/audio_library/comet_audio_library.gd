class_name CometAudioLibrary
extends Node

var _cached_children: Dictionary[String, CometLayeredAudioInstCache]

## mut (String) -> void
func play_audio(key_name: String) -> bool:
	return ICometAudioLibrary.play_audio(_cached_children, key_name)

## mut (CometAudioLayered, String?) -> bool
func register(
	node: Node, key_name: String = ""
) -> bool:
	return ICometAudioLibrary.register(_cached_children, node, key_name)

## mut (CometAudioLayered?, String?) -> bool
func unregister(
	node: Node, key_name: String = ""
) -> bool:
	return ICometAudioLibrary.unregister(_cached_children, node, key_name)

## (CometAudioLayered?, String?) -> bool
func is_registered(
	node: Node, key_name: String = ""
) -> bool:
	return ICometAudioLibrary.is_registered(_cached_children, node, key_name)

func _ready() -> void:
	for c in get_children():
		register(c)
