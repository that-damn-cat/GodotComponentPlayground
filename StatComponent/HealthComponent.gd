class_name HealthComponent
extends StatComponent

signal died

signal healed(amount: float)
signal damaged(amount: float)

@export var allow_negative_affects: bool = false

var is_dead: bool = false

var is_alive: bool:
	get:
		return not is_dead

var is_overhealed: bool:
	get:
		return value > max_value

var is_overkilled: bool:
	get:
		return value < min_value

func _ready() -> void:
	changed.connect(_on_health_changed)

func full_heal(can_resurrect: bool = false) -> void:
	if is_dead:
		if not can_resurrect:
			return
		resurrect(max_value)
		return
		
	fill()
	
func damage(amount: float) -> void:
	if is_dead:
		return
		
	if amount < 0:
		if not allow_negative_affects:
			return
			
		heal(abs(amount))
		return
		
	value -= amount
	
	if value <= min_value:
		is_dead = true
		died.emit()
	
func heal(amount: float, can_resurrect: bool = false) -> void:
	if is_dead and not can_resurrect:
		return
	
	if amount < 0:
		if not allow_negative_affects:
			return
			
		damage(abs(amount))
		return
	
	if is_dead:
		resurrect(amount)
	else:
		value += amount

func resurrect(new_health: float) -> void:
	if not is_dead:
		return
		
	assert(new_health > min_value, "Tried to resurrect with less than minimum health")
	
	value = new_health
	is_dead = false

func set_value(amount: float) -> void:
	if is_dead and amount > value:
		return
	
	super.set_value(amount)

func _on_health_changed(amount: float) -> void:
	if amount == 0:
		return
		
	if amount < 0:
		damaged.emit(abs(amount))
		return
	
	healed.emit(abs(amount))