class_name PadDisplay
extends Node2D

@onready var direction_anim: AnimationPlayer = $Direction/AnimationPlayer

func play_anim(anim_name: String):
	if direction_anim.is_playing():
		direction_anim.stop()
	direction_anim.play(anim_name)
