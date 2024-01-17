class_name PadDisplay
extends Node2D

@onready var direction_anim: AnimationPlayer = $Direction/AnimationPlayer
@onready var vertical_anim: AnimationPlayer = $Vertical/AnimationPlayer
@onready var horizontal_anim: AnimationPlayer = $Horizontal/AnimationPlayer

func play_anim(anim_name: String) -> void:
	if direction_anim.is_playing():
		direction_anim.stop()
	direction_anim.play(anim_name)

func bounce(horizontal: bool) -> void:
	if horizontal:
		horizontal_anim.play("bounce")
	else:
		vertical_anim.play("bounce")
