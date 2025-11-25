@icon("./heart.svg")
class_name HealthComponent
extends Node

signal died #emtis when out of hp

@export var max_health: int

var current_health: int:
	set(new_health):
		set_health(new_health)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	full_heal()


#sets health amount to max for full healing
func full_heal() -> void:
	set_health(max_health)


#subtracts health
func damage(amount: int) -> void:
	current_health -= amount

	#you fuckin died lol
	if current_health <= 0:
		current_health = 0
		died.emit()


#restores health
func heal(amount: int) -> void:
	current_health += amount

	#this caps the health so it cannot exceed max
	if current_health > max_health:
		current_health = max_health


#current health becomes the amount
func set_health(amount) -> void:
	current_health = amount

	#caps overheals and kills you if you're at zero lol
	if current_health > max_health:
		current_health = max_health

	if current_health <= 0:
		died.emit()
