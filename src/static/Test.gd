class_name Test
extends Object

const TESTS_ARE_FATAL := false

static func are_eq(actual: Variant, expected: Variant, msg := "") -> void:
	if actual == expected:
		return

	if TESTS_ARE_FATAL:
		assert(false, "%s, expected %s, got %s" % [msg, expected, actual])
	else:
		push_error("%s, expected %s, got %s" % [msg, expected, actual])

static func run(fn: Callable) -> void:
	if OS.has_feature("standalone"):
		return

	fn.call()
