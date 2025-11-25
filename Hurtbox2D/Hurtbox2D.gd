@icon("./targeted.svg")
class_name Hurtbox2D
extends Area2D

#drag and drop in the healthcomponent or the HEART of the entity
@export var health: HealthComponent


func _ready() -> void:
	area_entered.connect(_on_hit)


#did a hitbox touch me? noooooooooooo
func _on_hit(area: Area2D) -> void:
	if area is Hitbox2D:
		# We can use negative "damage" to heal
		if area.damage < 0:
			health.heal(area.damage)
		else:
			health.damage(area.damage)
