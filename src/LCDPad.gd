extends Control

@export var display: PadDisplay

@onready var pad: PressPad = $PressPad

func _ready() -> void:
	pad.pressed.connect(display.play_wave)
