class_name Grid
extends GridContainer

@export var direction_knob: SnappingKnob

var pads: Array[LCDPad]

func _ready() -> void:
	var pad_index: int = 0
	for i in range(get_child_count()):
		var c = get_child(i)
		assert(c is LCDPad, "Don't put anything that's not an LCDPad in the Grid!")

		c.pressed.connect(pad_pressed)
		pads.append(c)
		c.index = pad_index
		pad_index += 1

func get_direction() -> Game.PadState:
	assert(direction_knob.value >= 0 and direction_knob.value < 4, "Direction knob value must be in [0;3], got %d" % direction_knob.value)
	match direction_knob.value:
		0: return Game.PadState.UP
		1: return Game.PadState.RIGHT
		2: return Game.PadState.DOWN
		3: return Game.PadState.LEFT
		_: return Game.PadState.EMPTY

func pad_pressed(index: int) -> void:
	var current_state := pads[index].state

	if current_state == Game.PadState.EMPTY:
		pads[index].change_state(get_direction())
	else:
		pads[index].change_state(Game.PadState.EMPTY)
