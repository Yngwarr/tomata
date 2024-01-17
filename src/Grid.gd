class_name Grid
extends GridContainer

@export var direction_knob: SnappingKnob

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

	var pad_index: int = 0
	for i in range(get_child_count()):
		var c = get_child(i)
		assert(c is LCDPad, "Don't put anything besides LCDPads in the Grid!")

		c.pressed.connect(pad_pressed)
		c.index = pad_index
		pad_index += 1
		pads.append(c)
		buffer.append(Game.PadState.EMPTY)

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

func state_to(start: int, direction: Game.PadState) -> Game.PadState:
	var step_index := step_to(start, direction)

	if step_index == -1:
		return Game.PadState.WALL

	return pads[step_index].state

func step() -> void:
	var length := len(buffer)
	for i in range(length):
		buffer[i] = Game.PadState.EMPTY

	for i in range(length):
		var state = pads[i].state
		var left := state_to(i, Game.PadState.LEFT)
		var right := state_to(i, Game.PadState.RIGHT)
		var up := state_to(i, Game.PadState.UP)
		var down := state_to(i, Game.PadState.DOWN)

		if left & Game.PadState.RIGHT > 0: buffer[i] |= Game.PadState.RIGHT
		if right & Game.PadState.LEFT > 0: buffer[i] |= Game.PadState.LEFT
		if up & Game.PadState.DOWN > 0: buffer[i] |= Game.PadState.DOWN
		if down & Game.PadState.UP > 0: buffer[i] |= Game.PadState.UP

		# TODO add sounds here
		if state & Game.PadState.LEFT > 0 && left == Game.PadState.WALL:
			buffer[i] |= Game.PadState.RIGHT
		if state & Game.PadState.RIGHT > 0 && right == Game.PadState.WALL:
			buffer[i] |= Game.PadState.LEFT
		if state & Game.PadState.UP > 0 && up == Game.PadState.WALL:
			buffer[i] |= Game.PadState.DOWN
		if state & Game.PadState.DOWN > 0 && down == Game.PadState.WALL:
			buffer[i] |= Game.PadState.UP

	for i in range(length):
		pads[i].change_state(buffer[i])

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