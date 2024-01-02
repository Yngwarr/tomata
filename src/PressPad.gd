class_name PressPad
extends Control

signal pressed
signal released

@export var ease_time: float = .05

@onready var top_part: Control = $TopPart

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton\
		or event.button_index != MOUSE_BUTTON_LEFT:
		return

	var tween := create_tween()
	if event.pressed:
		tween.tween_property(top_part, "position", Vector2.DOWN * 4, .05).set_ease(Tween.EASE_OUT)
		pressed.emit()
	else:
		tween.tween_property(top_part, "position", Vector2.ZERO, .05).set_ease(Tween.EASE_IN)
		released.emit()
