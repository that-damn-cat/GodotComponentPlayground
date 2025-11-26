## A VisibleOnScreenNotifier2D which calls queue_free on its parent
## if it transitions from visible to not visible.
@icon("./sight-disabled.svg")
class_name FreeNotifier2D
extends VisibleOnScreenNotifier2D

var _wasVisible: bool = false
@onready var _parent: Node = get_parent()

func _process(delta: float) -> void:
	if not is_on_screen():
		if _wasVisible:
			_parent.queue_free()
	else:
		if not _wasVisible:
			_wasVisible = true
