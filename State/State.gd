## A node based State for the StateMachine

@icon("./choice.svg")
@tool
class_name State
extends Node

## Emits when this state is requesting a transition to a new state.
signal transitioned(this_state: State, new_state_name: String)

## The state name used to find this state in the StateMachine
@export var state_name: String = name.to_lower()

var _state_machine : StateMachine


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

	if Engine.is_editor_hint():
		if state_name == "":
			state_name = name.to_lower()
			notify_property_list_changed()

		if what in triggers:
			update_configuration_warnings()


## To be implemented by the inheriting node. Called when the state is first entered.
func enter() -> void:
	pass


## To be implemented by the inheriting node. Called when the state is exited.
func exit() -> void:
	pass


## To be implemented by the inheriting node. Called with _process
func update(_delta: float) -> void:
	pass


## To be implemented by the inheriting node. Called with _physics_process
func physics_update(_delta: float) -> void:
	pass


## Emit the transitioned signal
func transition_to(new_state_name: String) -> void:
	transitioned.emit(self, new_state_name)


func _exit_tree() -> void:
	if _state_machine:
		_state_machine.remove_state(self)
