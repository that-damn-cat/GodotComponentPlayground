## Hurtbox implementation of an Area2D. If it collides with a Hitbox2D
## it will transfer the damage to a given HealthComponent.
## Negative damage values will heal the HealthComponent instead.

@icon("./targeted.svg")
class_name Hurtbox2D
extends Area2D

## HealthComponent that accepts damage
@export var health: HealthComponent


func _ready() -> void:
	area_entered.connect(_on_hit)


func _on_hit(area: Area2D) -> void:
	if area is Hitbox2D:
		# We can use negative "damage" to heal
		if area.damage < 0:
			health.heal(area.damage)
		else:
			health.damage(area.damage)
