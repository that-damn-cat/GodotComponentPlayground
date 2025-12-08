## Node for tracking a Health value

@icon("./heart.svg")
class_name HealthComponent
extends Node

## Emits with HP is 0
signal died

## Emits on heal or full heal if actual amount healed > 0
signal healed(amount: float)

## Emits on damage if actual damage dealt > 0
signal damaged(amount: float)

## Health is clamped with this as it's maximum
@export var max_health: float

## Whether or not negative damage heals/negative healing damages
@export var allow_negative_amounts: bool = false

## Whether or not the entity is currently considered dead
var is_dead: bool = false

## internal representation of actual health value. Use current_health instead.
var _current_health: float = max_health

## Current health value. Changing this runs the appropriate checks automatically.
## Setting health to a positive value while dead will reset the is_dead flag.
var current_health: float:
	get:
		return _current_health
	set(new_health):
		set_health(new_health)


func _ready() -> void:
	full_heal()


## Sets health amount to max for full healing
func full_heal() -> void:
	current_health = max_health


## Subtracts health
func damage(amount: float) -> void:
	if is_dead:
		return

	if amount < 0:
		if not allow_negative_amounts:
			return

		heal(abs(amount))
		return

	current_health -= amount


## Restores health
func heal(amount: float, can_resurrect: bool = false) -> void:
	if is_dead and not can_resurrect:
		return

	if amount < 0:
		if not allow_negative_amounts:
			return

		damage(abs(amount))
		return

	current_health += amount


## Directly sets the health amount.
func set_health(amount) -> void:
	var original_health: float = current_health

	_current_health = amount

	# caps overheals and kills you if you're at zero
	_current_health = clamp(amount, 0, max_health)

	if current_health <= 0:
		is_dead = true
		died.emit()
	else:
		is_dead = false

	if original_health > current_health:
		damaged.emit(original_health - current_health)

	if original_health < current_health:
		healed.emit(current_health - original_health)