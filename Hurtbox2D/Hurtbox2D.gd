## Hurtbox implementation of an Area2D. If it collides with a Hitbox2D
## it will transfer the damage to a given HealthComponent.
## Negative damage values will heal the HealthComponent instead.

@icon("./targeted.svg")
class_name Hurtbox2D
extends Area2D

signal iframes_begin
signal iframes_end

## HealthComponent that accepts damage
@export var health: HealthComponent

## Number of seconds to remain invincible after being hit
@export_range(0.0, 9999.0, 0.01, "hide_slider") var iframes_seconds: float = 0.0

## Whether or not the hurtbox is currently in iframes
var in_iframes: bool = false
var _iframe_time: float = 0.0


func _ready() -> void:
	area_entered.connect(_on_hit)
	iframes_seconds = abs(iframes_seconds)


func _process(delta: float) -> void:
	if in_iframes:
		_iframe_time += delta

		if _iframe_time >= iframes_seconds:
			in_iframes = false
			_iframe_time = 0.0
			iframes_end.emit()


func _on_hit(area: Area2D) -> void:
	if not health or in_iframes:
		return

	if area is Hitbox2D:
		health.damage(area.damage)
		in_iframes = true
		_iframe_time = 0.0
		iframes_begin.emit()