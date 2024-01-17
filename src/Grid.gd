class_name Grid
extends GridContainer

signal bounced(number: int)

@export var direction_knob: SnappingKnob
@export var start_pad: PressPad
@export var beat_timer: Timer

var pads: Array[LCDPad]
var buffer: Array[int]

#   [*] < -> [*<]
#
# > [*]   -> [*>]
#
#    d
#   [*]   -> [*d]
#
#   [*]   -> [*^]
#    ^
#   [*]   -> [*]
#
#  |[<]   -> [>] s
#
#   [>]|  -> [<] s
#
#    _
#   [^]   -> [d] s
#
#   [d]   -> [^] s
#    -
#
#   [<]	  -> [ ]
#   [>]	  -> [ ]
#   [d]	  -> [ ]
#   [^]	  -> [ ]

func _ready() -> void:
	Test.run(test_near_walls)
	Test.run(test_step_to)
	Test.run(test_is_single_bit)
	Test.run(test_rotate_bits)

	start_pad.pressed.connect(on_start_pad_pressed)
	beat_timer.timeout.connect(step)

	var pad_index: int = 0
	for i in range(get_child_count()):
		var c = get_child(i)
		assert(c is LCDPad, "Don't put anything besides LCDPads in the Grid!")

		c.pressed.connect(pad_pressed)
		c.index = pad_index
		pad_index += 1
		pads.append(c)
		buffer.append(Game.PadState.EMPTY)

func on_start_pad_pressed():
	if beat_timer.is_stopped():
		step()
		beat_timer.start()
	else:
		beat_timer.stop()

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

func near_walls(index: int) -> int:
	var state: int = Game.PadState.EMPTY
	if index % columns == 0:
		state |= Game.PadState.LEFT
	if index % columns == columns - 1:
		state |= Game.PadState.RIGHT
	if index < columns:
		state |= Game.PadState.UP
	if index >= columns * (columns - 1):
		state |= Game.PadState.DOWN
	return state

func wall_ahead_to(start: int, direction: int) -> int:
	return near_walls(step_to(start, direction)) & direction != 0

func step_to(start: int, direction: Game.PadState) -> int:
	assert(direction != Game.PadState.EMPTY, "Direction can't be empty.")
	assert(direction != Game.PadState.WALL, "Direction can't be a wall.")

	var walls := near_walls(start)

	if direction & walls > 0:
		return -1

	match direction:
		Game.PadState.LEFT:
			return start - 1
		Game.PadState.RIGHT:
			return start + 1
		Game.PadState.UP:
			return start - columns
		Game.PadState.DOWN:
			return start + columns
		_:
			return -1

func state_to(start: int, direction: Game.PadState, on_buffer := false) -> int:
	var step_index := step_to(start, direction)

	if step_index == -1:
		return Game.PadState.WALL

	return buffer[step_index] if on_buffer else pads[step_index].state

func is_horizontal(state: int) -> bool:
	return state == Game.PadState.LEFT \
		|| Game.PadState.RIGHT

func is_single_bit(state: int) -> bool:
	return state == Game.PadState.LEFT \
		|| state == Game.PadState.RIGHT \
		|| state == Game.PadState.UP \
		|| state == Game.PadState.DOWN

func rotate_bits(state: int) -> int:
	var new_state: int = 0

	if state & Game.PadState.LEFT != 0: new_state |= Game.PadState.UP
	if state & Game.PadState.UP != 0: new_state |= Game.PadState.RIGHT
	if state & Game.PadState.RIGHT != 0: new_state |= Game.PadState.DOWN
	if state & Game.PadState.DOWN != 0: new_state |= Game.PadState.LEFT

	return new_state

func step() -> void:
	var length := len(buffer)
	for i in range(length):
		var state: int = pads[i].state

		if not is_single_bit(state):
			pads[i].state = rotate_bits(state)

		buffer[i] = Game.PadState.EMPTY

	for i in range(length):
		var state: int = pads[i].state
		var left := state_to(i, Game.PadState.LEFT)
		var right := state_to(i, Game.PadState.RIGHT)
		var up := state_to(i, Game.PadState.UP)
		var down := state_to(i, Game.PadState.DOWN)

		if left & Game.PadState.RIGHT > 0: buffer[i] |= Game.PadState.RIGHT
		if right & Game.PadState.LEFT > 0: buffer[i] |= Game.PadState.LEFT
		if up & Game.PadState.DOWN > 0: buffer[i] |= Game.PadState.DOWN
		if down & Game.PadState.UP > 0: buffer[i] |= Game.PadState.UP

		if left & Game.PadState.LEFT:
			if wall_ahead_to(i, Game.PadState.LEFT):
				buffer[i] |= Game.PadState.RIGHT
		if right & Game.PadState.RIGHT:
			if wall_ahead_to(i, Game.PadState.RIGHT):
				buffer[i] |= Game.PadState.LEFT
		if up & Game.PadState.UP:
			if wall_ahead_to(i, Game.PadState.UP):
				buffer[i] |= Game.PadState.DOWN
		if down & Game.PadState.DOWN:
			if wall_ahead_to(i, Game.PadState.DOWN):
				buffer[i] |= Game.PadState.UP

	for i in range(length):
		pads[i].change_state(buffer[i])

		if buffer[i] != Game.PadState.EMPTY \
			and is_single_bit(buffer[i]) \
			and state_to(i, buffer[i], true) == Game.PadState.WALL:

			@warning_ignore("integer_division")
			bounced.emit(i % columns if is_horizontal(buffer[i]) else i / columns)

func test_near_walls() -> void:
	assert(columns > 1, "this test makes no sense when columns == 1")

	Test.are_eq(near_walls(0), Game.PadState.LEFT | Game.PadState.UP,
			"top-left corner doesn't register properly")
	Test.are_eq(near_walls(columns - 1), Game.PadState.RIGHT | Game.PadState.UP,
			"top-right corner doesn't register properly")
	Test.are_eq(near_walls(columns * (columns - 1)), Game.PadState.LEFT | Game.PadState.DOWN,
			"bottom-left corner doesn't register properly")
	Test.are_eq(near_walls(columns ** 2 - 1), Game.PadState.RIGHT | Game.PadState.DOWN,
			"bottom-right corner doesn't register properly")

func test_step_to() -> void:
	assert(columns > 2, "this test makes no sense when columns < 3")

	var top_left = 0
	var top_right = columns - 1
	var bottom_left = columns * (columns - 1)
	var bottom_right = columns ** 2 - 1
	@warning_ignore("integer_division")
	var center = columns ** 2 / 2 + 1

	Test.are_eq(step_to(center, Game.PadState.LEFT), center - 1,
			"got confused moving left from the center")
	Test.are_eq(step_to(center, Game.PadState.RIGHT), center + 1,
			"got confused moving right from the center")
	Test.are_eq(step_to(center, Game.PadState.UP), center - columns,
			"got confused moving up from the center")
	Test.are_eq(step_to(center, Game.PadState.DOWN), center + columns,
			"got confused moving down from the center")

	Test.are_eq(step_to(top_left, Game.PadState.LEFT), -1,
			"can go left through the wall from the top-left corner")
	Test.are_eq(step_to(top_left, Game.PadState.RIGHT), top_left + 1,
			"got confused moving right from the top-left corner")
	Test.are_eq(step_to(top_left, Game.PadState.UP), -1,
			"can go up through the wall from the top-left corner")
	Test.are_eq(step_to(top_left, Game.PadState.DOWN), top_left + columns,
			"got confused moving down from the top-left corner")

	Test.are_eq(step_to(top_right, Game.PadState.LEFT), top_right - 1,
			"got confused moving left from the top-right corner")
	Test.are_eq(step_to(top_right, Game.PadState.RIGHT), -1,
			"can go right through the wall from the top-right corner")
	Test.are_eq(step_to(top_right, Game.PadState.UP), -1,
			"can go up through the wall from the top-right corner")
	Test.are_eq(step_to(top_right, Game.PadState.DOWN), top_right + columns,
			"got confused moving down from the top-right corner")

	Test.are_eq(step_to(bottom_left, Game.PadState.LEFT), -1,
			"can go left through the wall from the bottom-left corner")
	Test.are_eq(step_to(bottom_left, Game.PadState.RIGHT), bottom_left + 1,
			"got confused moving right from the bottom-left corner")
	Test.are_eq(step_to(bottom_left, Game.PadState.UP), bottom_left - columns,
			"got confused moving up from the bottom-left corner")
	Test.are_eq(step_to(bottom_left, Game.PadState.DOWN), -1,
			"can go down through the wall from the bottom-left corner")

	Test.are_eq(step_to(bottom_right, Game.PadState.LEFT), bottom_right - 1,
			"got confused moving left from the bottom-right corner")
	Test.are_eq(step_to(bottom_right, Game.PadState.RIGHT), -1,
			"can go right through the wall from the bottom-right corner")
	Test.are_eq(step_to(bottom_right, Game.PadState.UP), bottom_right - columns,
			"got confused moving up from the bottom-right corner")
	Test.are_eq(step_to(bottom_right, Game.PadState.DOWN), -1,
			"can go down through the wall from the bottom-right corner")

func test_is_single_bit() -> void:
	Test.are_eq(is_single_bit(1), true)
	Test.are_eq(is_single_bit(2), true)
	Test.are_eq(is_single_bit(3), false)
	Test.are_eq(is_single_bit(4), true)
	Test.are_eq(is_single_bit(5), false)
	Test.are_eq(is_single_bit(6), false)
	Test.are_eq(is_single_bit(7), false)
	Test.are_eq(is_single_bit(8), true)

func test_rotate_bits() -> void:
	Test.are_eq(rotate_bits(Game.PadState.LEFT | Game.PadState.RIGHT),
			Game.PadState.UP | Game.PadState.DOWN)
	Test.are_eq(rotate_bits(Game.PadState.UP | Game.PadState.DOWN),
			Game.PadState.LEFT | Game.PadState.RIGHT)
	Test.are_eq(rotate_bits(Game.PadState.LEFT | Game.PadState.UP),
			Game.PadState.UP | Game.PadState.RIGHT)
	Test.are_eq(rotate_bits(Game.PadState.LEFT | Game.PadState.RIGHT | Game.PadState.UP),
			Game.PadState.UP | Game.PadState.DOWN | Game.PadState.RIGHT)
