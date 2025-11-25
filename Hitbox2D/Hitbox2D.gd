@icon("./punch-blast.svg")
class_name Hitbox2D
extends Area2D

signal hit_target

@export var damage: int


func _ready() -> void:
	area_entered.connect(_on_hit)


#where to change the amount of damage a thing has done
func set_damage(value: int) -> void:
	damage = value


#damage multipler or divider
func get_scaled_damage(factor: float) -> int:
	var result: int = (damage * factor) as int

	return (result)


#did i hit something? if its a hurtbox E M I T
func _on_hit(area: Area2D) -> void:
	if area is Hurtbox2D:
		hit_target.emit()
