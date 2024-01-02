class_name SnappingKnob
extends Control

signal grabbed
signal released
signal value_changed(value: float)

@export_category("Value")
@export var default_value: int = 5
@export var lowest_value: int = 0
@export var highest_value: int = 10
@export var snap_step: int = 1

@export_category("Rotation")
@export var knob_step: float = .05
@export var lowest_degrees: float = -170
@export var highest_degrees: float = 170

var value: int

@onready var knob: Knob = $Knob

func knob_value_to_snapped(knob_value: float) -> int:
	return snapped(knob_value, snap_step)

func _ready() -> void:
	knob.default_value = default_value
	knob.lowest_value = lowest_value
	knob.highest_value = highest_value
	knob.step = knob_step
	knob.lowest_degrees = lowest_degrees
	knob.highest_degrees = highest_degrees

	knob.grabbed.connect(on_grabbed)
	knob.released.connect(on_released)
	knob.value_changed.connect(on_value_changed)

	knob.set_value(default_value, true)
	value = knob_value_to_snapped(knob.value)

func on_grabbed() -> void:
	grabbed.emit()

func on_released() -> void:
	knob.set_value(value, true)
	released.emit()

func on_value_changed(knob_value: float) -> void:
	var new_value: int = knob_value_to_snapped(knob_value)

	if new_value == value:
		return

	knob.set_value(new_value, true)
	value = new_value

	print("snap value ", value)
	value_changed.emit(value)
