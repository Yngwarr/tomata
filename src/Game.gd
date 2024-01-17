class_name Game
extends Node2D

## The game node, the beginning of all, the almighty entry point, the place,
## where your dreams come true! Adjust to your likings and may the code be with
## you.

@onready var start_pad: PressPad = $StartPad
@onready var direction_knob: SnappingKnob = $DirectionKnob

enum PadState {
	EMPTY = 0,
	UP    = 0b00001,
	RIGHT = 0b00010,
	DOWN  = 0b00100,
	LEFT  = 0b01000,
	WALL  = 0b10000
}

func _ready() -> void:
	start_pad.pressed.connect(start)

func start() -> void:
	pass
