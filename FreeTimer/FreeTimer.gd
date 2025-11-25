@icon("./stopwatch.svg")
class_name FreeTimer
extends Timer

@onready var parent_node = get_parent()


func _ready() -> void:
	timeout.connect(_on_timeout)


func _on_timeout() -> void:
	parent_node.queue_free()
