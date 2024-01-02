class_name Knob
extends Control

signal grabbed
signal released
signal value_changed(value: float)

@export_category("Value")
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
	print("knob ready")

func _gui_input(event: InputEvent) -> void:
	handle_click(event)
	handle_movement(event)

func get_degrees_from_value(val: float) -> float:
	var clamped: float = clamp(val, lowest_value, highest_value)
	var whole := highest_value - lowest_value
	var part := clamped / whole
	var whole_degrees := highest_degrees - lowest_degrees

	return lowest_degrees + whole_degrees * part

func set_value(new_value: float, silent := false) -> void:
	var clamped: float = clamp(new_value, lowest_value, highest_value)

	top.rotation_degrees = get_degrees_from_value(clamped)
	value = clamped
	if not silent:
		value_changed.emit(value)

func handle_movement(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	if not is_grabbed:
		return

	var delta: float = -event.relative.y * step
	set_value(value + delta)

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
