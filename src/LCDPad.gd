class_name LCDPad
extends Control

signal pressed(index: int)
signal released(index: int)

@export var display: PadDisplay

@onready var pad: PressPad = $PressPad

var index: int
var state: int

func _ready() -> void:
	pad.pressed.connect(on_pressed)
	pad.released.connect(on_released)

func on_pressed() -> void:
	pressed.emit(index)

func on_released() -> void:
	released.emit(index)

func change_state(value: Game.PadState) -> void:
	state = value
	match value:
		Game.PadState.UP: display.play_anim("up")
		Game.PadState.DOWN: display.play_anim("down")
		Game.PadState.LEFT: display.play_anim("left")
		Game.PadState.RIGHT: display.play_anim("right")
		Game.PadState.EMPTY: display.play_anim("RESET")
		_: display.play_anim("wave")
