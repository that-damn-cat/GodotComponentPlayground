## Spawner implementation of a Timer. Can autospawn on timer completion or used as
## a spawn "cooldown" with try_spawn.

@icon("./riposte.svg")
class_name Spawner
extends Timer

## Emitted when the scene is spawned. Entity contains a reference to the node spawned.
signal spawned(entity: Node)

## Scene to Spawn
@export var scene_to_spawn: PackedScene

## Scene will be spawned as a child of this Marker2D
@export var spawn_position: Marker2D

## When true, spawns automatically when timer complete.
@export var auto_spawn: bool

## If set, this function is called when spawning an entity.
## It must take the spawned node as its only parameter.
var spawn_function: Callable = Callable()

## Whether or not a spawn request would currently succeed
var can_spawn: bool = true


func _ready() -> void:
	timeout.connect(_on_spawner_timeout)

	if auto_spawn:
		autostart = true
		start()


## Try to spawn the scene if the timer/delay is OK.
## The spawn_action is optionally called and must take the spawned node as its only parameter.
## If nothing is set, the spawn_function Callable is used.
## If that is also not set, no function is called.
## Returns true if spawned, false if not.
func try_spawn(spawn_action: Callable = spawn_function) -> bool:
	if not can_spawn:
		return false

	spawn(spawn_action)
	return true


## Spawn the scene immediately. The spawn_action is
## optionally called and must take the spawned node as its only parameter.
## If nothing is set, the spawn_function Callable is used.
## If that is also not set, no function is called.
func spawn(spawn_action: Callable = spawn_function) -> void:
	if not scene_to_spawn:
		push_warning("Spawner scene is not set!")
		return

	var new_entity: Node = scene_to_spawn.instantiate()

	if spawn_position:
		new_entity.global_position = spawn_position.global_position
		spawn_position.add_child(new_entity)
	else:
		get_tree().current_scene.add_child(new_entity)
		new_entity.global_position = Vector2.ZERO

	if spawn_action.is_valid():
		spawn_action.call(new_entity)

	spawned.emit(new_entity)
	can_spawn = false
	start()


func _on_spawner_timeout() -> void:
	can_spawn = true

	if auto_spawn:
		spawn()
