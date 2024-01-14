class_name PadDisplay
extends Sprite2D

@onready var anim: AnimationPlayer = $AnimationPlayer

func play_anim(anim_name: String):
	if anim.is_playing():
		anim.stop()
	anim.play(anim_name)

## deprecated
func play_wave() -> void:
	play_anim("wave")
