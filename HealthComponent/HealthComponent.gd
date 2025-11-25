@icon("./heart.svg")
class_name HealthComponent
extends Node

## Emits with HP is 0
signal died

## Emits on heal or full heal if actual amount healed > 0
signal healed(amount: int)

## Emits on damage if actual damage dealt > 0
signal damaged(amount: int)

@export var max_health: int

## internal representation of actual health value. Use current_health instead.
var _current_health : int

## Current health value. Changing this runs the appropriate checks automatically.
var current_health: int:
	get:
		return _current_health
	set(new_health):
		set_health(new_health)


func _ready() -> void:
	set_health(max_health)


## Sets health amount to max for full healing
func full_heal() -> void:
	var original_health := current_health
	set_health(max_health)

	if current_health > original_health:
		healed.emit(current_health - original_health)


## Subtracts health
func damage(amount: int) -> void:
	var original_health = current_health
	set_health(current_health - amount)

	if current_health < original_health:
		damaged.emit(original_health - current_health)


# Restores health
func heal(amount: int) -> void:
	var original_health = current_health
	set_health(current_health + amount)

	if current_health > original_health:
		damaged.emit(current_health - original_health)


# Directly sets the health amount
func set_health(amount) -> void:
	_current_health = amount

	# caps overheals and kills you if you're at zero
	_current_health = clamp(amount, 0, max_health)

	if current_health <= 0:
		died.emit()