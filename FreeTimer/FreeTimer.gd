## A Timer that calls queue_free on its parent when the timer completes

@icon("./stopwatch.svg")
class_name FreeTimer
extends Timer

## When enabled, will defer the queue_free call to the next frame.
## This is the safe way of freeing a node, but you lose 1 frame of precision
@export var defer_call: bool = true
@onready var _parent = get_parent()


func _ready() -> void:
	timeout.connect(_on_timeout)


func _on_timeout() -> void:
	if defer_call:
		_parent.call_deferred("queue_free")
	else:
		_parent.queue_free()
