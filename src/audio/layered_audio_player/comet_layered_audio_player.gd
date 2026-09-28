class_name CometLayeredAudioPlayer
extends Node

var _cached_children: Array[CometAudioInstCache] = []

## mut () -> void
func play_audio() -> void:
	return ICometLayeredAudioPlayer.play_audio(_cached_children)

## mut (CometAudioPlayable) -> bool
func register(node: Node) -> bool:
	return ICometLayeredAudioPlayer.register(_cached_children, node)

## mut (CometAudioPlayable) -> bool
func unregister(node: Node) -> bool:
	return ICometLayeredAudioPlayer.unregister(_cached_children, node)

## (CometAudioPlayable) -> bool
func is_registered(node: Node) -> bool:
	return ICometLayeredAudioPlayer.is_registered(_cached_children, node)

func _ready() -> void:
	for c in get_children():
		ICometLayeredAudioPlayer.register(_cached_children, c)
