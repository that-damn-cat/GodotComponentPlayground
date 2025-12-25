## A node based State for the StateMachine

@icon("./choice.svg")
class_name State
extends Node

## Emits when this state is requesting a transition to a new state.
signal transitioned(this_state: State, new_state_name: StringName)

## The state name used to find this state in the StateMachine
@export var state_name: StringName

## Holds a reference to the StateMachine that controls this State
var state_machine: StateMachine

var is_active: bool:
	get:
		return(state_machine.current_state == self)


func _ready() -> void:
	if get_parent() is not StateMachine:
		push_error("State nodes must be children of a StateMachine Node!")

	if state_name == "":
		state_name = name.to_lower()


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
	transitioned.emit(self, StringName(new_state_name))


func _exit_tree() -> void:
	if state_machine:
		state_machine.remove_state(self)
