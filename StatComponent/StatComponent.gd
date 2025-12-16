class_name StatComponent
extends Node

signal changed(delta: float)

@export var max_value: float
@export var min_value: float = 0.0
@export var use_initial_value: bool = false
@export var initial_value: float
@export var allow_overfill: bool = false
@export var allow_underflow: bool = false

var _current_value: float = 0.0

var is_empty: bool:
	get:
		return _current_value <= min_value
		
var is_full: bool:
	get:
		return _current_value >= max_value

var value: float:
	get: 
		return _current_value
	set(new_value: float):
		set_value(new_value)
		
var percentage: float:
	get:
		return _current_value / max_value
	set(new_value: float):
		set_value(new_value * max_value)

func _ready():
	assert(min_value < max_value, "Min value should be smaller than Max value!")
	
	if use_initial_value:
		value = initial_value
	else:
		value = max_value
		
func fill() -> void:
	value = max_value
	
func set_value(amount: float) -> void:
	var original: float = _current_value
	
	if allow_overfill and allow_underflow:
		_current_value = amount
	elif allow_overfill:
		_current_value = max(amount, min_value)
	elif allow_underflow:
		_current_value = min(amount, max_value)
	else:
		_current_value = clamp(amount, min_value, max_value)
	
	if _current_value != original:
		changed.emit(_current_value - original)