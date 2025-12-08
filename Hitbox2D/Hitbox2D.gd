## Hitbox implementation of an Area2D. If it collides with a Hurtbox2D
## it will deal damage to it.

@icon("./punch-blast.svg")
class_name Hitbox2D
extends Area2D

## Emitted when a collision with a Hurtbox2D is detected
signal hit_hurtbox(hurtbox: Hurtbox2D)

## Amount of damage to deal to collided Hurtbox2D
@export var damage: int


func _ready() -> void:
	area_entered.connect(_on_hit)


func _on_hit(area: Area2D) -> void:
	if not area is Hurtbox2D:
		return

	if not area.in_iframes:
		hit_hurtbox.emit(area as Hurtbox2D)