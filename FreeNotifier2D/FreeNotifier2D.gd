## A VisibleOnScreenNotifier2D which calls queue_free on its parent
## if it transitions from visible to not visible.
@icon("./sight-disabled.svg")
class_name FreeNotifier2D
extends VisibleOnScreenNotifier2D

@onready var _parent: Node = get_parent()
var _was_visible: bool = false

func _ready() ->  void:
	screen_entered.connect(_on_screen_entered)
	screen_exited.connect(_on_screen_exited)

func _on_screen_entered() -> void:
	_was_visible = true

func _on_screen_exited() -> void:
	if _was_visible:
		_parent.call_deferred("queue_free")