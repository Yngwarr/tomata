class_name Knob
extends Control

signal grabbed
signal released
signal value_changed

@export_category("Value")
@export var integer := false
@export var default_value: float = 50
@export var lowest_value: float = 0
@export var highest_value: float = 100

@export_category("Rotation")
@export var step: float = 1
@export var lowest_degrees: float = -170
@export var highest_degrees: float = 170

var is_grabbed := false
var value: float

@onready var top: Control = $TopPart

func _ready() -> void:
	set_value(default_value)

func _gui_input(event: InputEvent) -> void:
	handle_click(event)
	handle_movement(event)

func set_value(new_value: float) -> void:
	var clamped = clamp(new_value, lowest_value, highest_value)
	var whole = highest_value - lowest_value
	var part = clamped / whole
	var whole_degrees = highest_degrees - lowest_degrees

	top.rotation_degrees = lowest_degrees + whole_degrees * part
	value = clamped
	print("value ", value)

func handle_movement(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	if not is_grabbed:
		return

	var delta = -event.relative.y * step
	set_value(int(value + delta) if integer else value + delta)

func handle_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton\
		or event.button_index != MOUSE_BUTTON_LEFT:
		return

	if event.pressed:
		is_grabbed = true
		grabbed.emit()
	else:
		is_grabbed = false
		released.emit()
