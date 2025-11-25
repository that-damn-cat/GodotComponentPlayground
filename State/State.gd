@icon("./choice.svg")
@tool
class_name State
extends Node

signal transitioned(this_state: State, new_state_name: String)
var state_machine : StateMachine

@export var state_name: String = name.to_lower()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if get_parent() is not StateMachine:
		warnings.append("State nodes must be children of a StateMachine node.")

	return warnings

func _notification(what: int) -> void:
	var triggers := [
			NOTIFICATION_READY,
			NOTIFICATION_CHILD_ORDER_CHANGED,
			NOTIFICATION_EDITOR_POST_SAVE,
	]

	if state_name == "":
		state_name = name.to_lower()
		notify_property_list_changed()

	if Engine.is_editor_hint() and what in triggers:
		update_configuration_warnings()

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func _exit_tree() -> void:
	if state_machine:
		state_machine.remove_state(self)