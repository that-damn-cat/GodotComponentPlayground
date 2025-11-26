## A Timer that calls queue_free on its parent when the timer completes

@icon("./stopwatch.svg")
class_name FreeTimer
extends Timer

@onready var _parent = get_parent()


func _ready() -> void:
	timeout.connect(_on_timeout)


func _on_timeout() -> void:
	_parent.queue_free()
