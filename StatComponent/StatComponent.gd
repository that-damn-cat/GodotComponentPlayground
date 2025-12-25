## Node for tracking generic stat values

@icon("./dice-twenty.svg")
class_name StatComponent
extends Node

# Notifies when current value changes
signal changed(delta: float)

## Defines the "full" status
@export var max_value: float

## Whether or not values above the maximum are allowed
@export var allow_overflow: bool = false

## Defines the "empty" status
@export var min_value: float = 0.0

## Whether or not values below the minimum are allowed
@export var allow_underflow: bool = false

## When true, value will be set to initial_value on _ready
## When false, value will be set to max_value on _ready
@export var use_initial_value: bool = false
@export var initial_value: float

var _current_value: float = 0.0

## Whether or not the current value is <= min
var is_empty: bool:
	get:
		return _current_value <= min_value

## Whether or not the current value is >= max
var is_full: bool:
	get:
		return _current_value >= max_value

## The current value. Setting this is the same as using set_value()
var value: float:
	get:
		return _current_value
	set(new_value):
		set_value(new_value)

## The current value, normalized to the range from min -> max
var percentage: float:
	get:
		return get_percentage()
	set(new_value):
		set_percentage(new_value)


func _ready():
	assert(min_value < max_value, "Min value should be smaller than Max value!")

	if use_initial_value:
		value = initial_value
	else:
		value = max_value


## Set value to maximum
func fill() -> void:
	value = max_value


## Set a value, respecting minimums, maximums, and overflow/underflow rules
func set_value(amount: float) -> void:
	var original: float = _current_value

	var lower: float = min_value if not allow_underflow else -INF
	var upper: float = max_value if not allow_overflow else INF

	_current_value = clamp(amount, lower, upper)

	if _current_value != original:
		changed.emit(_current_value - original)


## Returns the current percent full, as defined by the range from min -> max
func get_percentage() -> float:
	if min_value == max_value:
		push_warning("minimum value == maximum value! Percentage invalid!")
		return 0.0

	return (value - min_value) / (max_value - min_value)


## Sets the value to match the given percentage full using the range from min -> max
func set_percentage(new_percentage: float) -> void:
	set_value(min_value + new_percentage * (max_value - min_value))