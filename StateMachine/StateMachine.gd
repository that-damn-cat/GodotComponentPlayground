## A Node based state machine that manages State children and handles transitions
@icon("./gears.svg")
class_name StateMachine
extends Node

## Emitted when a state transition occurs
signal state_changed(old: State, new: State)

## The state set at _ready
@export var initial_state: State

## Dictionary of currently configured states
var states: Dictionary[StringName, State] = { }

## Current state
var current_state: State

## Last running state
var previous_state: State


func _enter_tree() -> void:
	states = { }

	for child in get_children():
		if child is State:
			add_state(child)


func _ready() -> void:
	if initial_state:
		_set_state(initial_state)

	if states.size() == 0:
		push_warning("StateMachine has no State children at ready!")


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


## Returns the state object with the given name
func get_state(state_name: String) -> State:
	return(states.get(state_name))


## Adds a given state to the State Machine
func add_state(new_state: State) -> void:
	new_state.state_machine = self

	# The new state must be a direct child of the StateMachine. Put it there if it isn't.
	if not new_state.get_parent() == self:
		# Defer calls to end of frame in case reparenting is already happening from somewhere else
		new_state.get_parent().call_deferred("remove_child", new_state)
		self.call_deferred("add_child", new_state)

	if states.has(new_state.state_name):
		push_warning("Duplicate state_name '%s' detected. State being overwritten!" % new_state.state_name)
		remove_state(new_state)

	states[new_state.state_name] = new_state
	new_state.transitioned.connect(_on_state_transitioned)

## Removes a given state from the State Machine, leaving it in the tree.
## If the removed state is the current state, becomes stateless.
## If the removed state is previous or initial, remove the references.
func remove_state(state_to_remove: State) -> void:
	if not states.has(state_to_remove.state_name):
		push_warning("Error trying to remove state '%s', state not in dictionary!" % state_to_remove.state_name)
		return

	# Remove references to the removed state in previous/initial
	if state_to_remove == previous_state:
		previous_state = null

	if state_to_remove == initial_state:
		initial_state = null

	# If we are removing the current state, try to handle it gracefully.
	if state_to_remove == current_state:
		current_state.exit()
		current_state = null

	# Remove it from the dictionary and disconnect its transition signal
	states.erase(state_to_remove.state_name)
	state_to_remove.transitioned.disconnect(_on_state_transitioned)


## Returns whether the State Machine has a state with the given name.
func has_state(state_name: String) -> bool:
	return states.has(state_name)


## Forces a state change to the given state name.
func change_state(new_state_name: String) -> void:
	var new_state: State = get_state(new_state_name)

	if not new_state:
		push_error("State '%s' does not exist in the state machine." % new_state_name)
		return

	_set_state(new_state)


func _on_state_transitioned(this_state: State, new_state_name: String) -> void:
	if this_state != current_state:
		push_warning("State transition signal received from a state '%s' which is not the current state!" % this_state.state_name)
		return

	var new_state: State = get_state(new_state_name)
	if !new_state:
		push_error("State '%s' does not exist in the state machine." % new_state_name)
		return

	_set_state(new_state)


func _set_state(new_state: State) -> void:
	if not new_state:
		current_state = null
		return

	if new_state == current_state:
		return

	if current_state:
		current_state.exit()
		previous_state = current_state

	current_state = new_state
	current_state.enter()
	state_changed.emit(previous_state, current_state)