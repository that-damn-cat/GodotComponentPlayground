## Node for tracking a healh value

@icon("./heart.svg")
class_name HealthComponent
extends StatComponent

## Emits when HP drops below minimum
signal died

## Emits when the is_dead state becomes false
signal resurrected

## Emits when value increases
signal healed(amount: float)

## Emits when value decreases
signal damaged(amount: float)

## Whether or not negative damage heals/negative healing damages
@export var allow_negative_effects: bool = false

## Current dead state. Becomes true when health <= minimum
## Becomes false when resurrection occurs
var is_dead: bool = false

## Inverse of is_dead
var is_alive: bool:
	get:
		return not is_dead

## Whether or not value > max
var is_overhealed: bool:
	get:
		return value > max_value

## Whether or not value < min
var is_overkilled: bool:
	get:
		return value < min_value

## Alias for value
var health: float:
	get:
		return value
	set(new_value):
		value = new_value


func _ready() -> void:
	super()
	changed.connect(_on_health_changed)

	if value <= min_value:
		is_dead = true

## Sets health amount to max, optionally resurrecting
func full_heal(can_resurrect: bool = false) -> void:
	if is_dead:
		if can_resurrect:
			resurrect(max_value)
		return

	fill()


## Subtracts health
func damage(amount: float) -> void:
	if is_dead:
		return

	if amount < 0:
		if allow_negative_effects:
			heal(-amount)
		return

	value -= amount

	if value <= min_value:
		_die()


## Restores health, optionally resurrecting.
func heal(amount: float, can_resurrect: bool = false) -> void:
	if amount < 0:
		if allow_negative_effects:
			damage(-amount)
		return

	if is_dead:
		if can_resurrect:
			resurrect(amount)
		return

	value += amount


## If dead, resurrect and set health = new_health
func resurrect(new_health: float) -> void:
	assert(new_health > min_value, "Tried to resurrect with less than minimum health")
	_resurrect(new_health)


## Sets health = min and is_dead
func kill() -> void:
	if is_dead:
		return

	value = min_value
	_die()


func _die() -> void:
	if is_dead:
		return

	is_dead = true
	died.emit()


func _resurrect(new_health: float) -> void:
	if not is_dead:
		return

	is_dead = false
	value = new_health
	resurrected.emit()


func _on_health_changed(delta: float) -> void:
	if delta == 0:
		return

	if delta < 0:
		damaged.emit(abs(delta))
	else:
		healed.emit(abs(delta))

	# Edge case: Die if value drops <= minimum without the flag getting set
	# This can happen if the value is set directly instead of using damage()
	if not is_dead and value <= min_value:
		_die()