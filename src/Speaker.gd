class_name Speaker
extends Node

var player: Array[AudioStreamPlayer]

func _ready() -> void:
	for c in get_children():
		assert(c is AudioStreamPlayer, "Speaker can only contain AudioStreamPlayer nodes")
		player.append(c)

func play_sound(number: int) -> void:
	player[number].play()
