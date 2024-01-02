class_name PadDisplay
extends Sprite2D

@onready var anim: AnimationPlayer = $AnimationPlayer

func play_wave() -> void:
	if anim.is_playing():
		anim.stop()
	anim.play("wave")
