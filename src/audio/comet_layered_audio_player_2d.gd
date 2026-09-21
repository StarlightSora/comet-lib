class_name CometLayeredAudioPlayer2D
extends Node2D

var _cached_children: Array[CometAudioInstCache] = []

## mut () -> void
func play_audio() -> void:
	return ICometLayeredAudioPlayer.play_audio(_cached_children)

## mut (T) -> bool
## where T: extends CometAudioStreamPlayer or AudioStreamPlayer
func register(node: Node) -> bool:
	return ICometLayeredAudioPlayer.register(_cached_children, node)

## mut (T) -> bool
## where T: extends CometAudioStreamPlayer or AudioStreamPlayer
func unregister(node: Node) -> bool:
	return ICometLayeredAudioPlayer.unregister(_cached_children, node)

## (T) -> bool
## where T: extends CometAudioStreamPlayer or AudioStreamPlayer
func is_registered(node: Node) -> bool:
	return ICometLayeredAudioPlayer.is_registered(_cached_children, node)

func _ready() -> void:
	for c in get_children():
		ICometLayeredAudioPlayer.register(_cached_children, c)
