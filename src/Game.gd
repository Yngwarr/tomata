class_name Game
extends Node2D

## The game node, the beginning of all, the almighty entry point, the place,
## where your dreams come true! Adjust to your likings and may the code be with
## you.

@onready var start_pad: PressPad = $StartPad
@onready var direction_knob: SnappingKnob = $DirectionKnob

enum PadState { EMPTY, UP, RIGHT, DOWN, LEFT }

func _ready() -> void:
	start_pad.pressed.connect(start)

func start() -> void:
	pass
