## A Node based state machine that manages State children and handles transitions

@tool
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
	if Engine.is_editor_hint():
		return

	states = { }

	for child in get_children():
		if child is State:
			add_state(child)


func _ready() -> void:
	if initial_state:
		_set_state(initial_state)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if current_state:
		current_state.physics_update(delta)


## Returns the state object with the given name
func get_state(state_name : String) -> State:
	return(states.get(state_name))


## Adds a given state to the State Machine
func add_state(new_state : State) -> void:
	new_state.state_machine = self

	# The new state must be a direct child of the StateMachine.
	if new_state.get_parent() != self:
		new_state.get_parent().remove_child(new_state)
		add_child(new_state)

	if states.has(new_state.state_name):
		push_warning("Duplicate state_name '%s' detected." % new_state.state_name)

	states[new_state.state_name] = new_state
	new_state.transitioned.connect(_on_state_transitioned)

## Removes a given state from the State Machine, leaving it in the tree.
## If the removed state is the current state, transitions to the previous state.
## If there is no previous state, transitions to the initial state.
## Finally, if there is no initial state, the StateMachine will have no current state.
func remove_state(state_to_remove: State) -> void:
	if not states.has(state_to_remove.state_name):
		return

	# Remove references to the removed state in previous/initial
	if state_to_remove == previous_state:
		previous_state = null

	if state_to_remove == initial_state:
		initial_state = null

	# If we are removing the current state, try to handle it gracefully.
	if state_to_remove == current_state:
		if previous_state:
			change_state(previous_state.state_name)
		elif initial_state:
			change_state(initial_state.state_name)
		else:
			current_state = null

	states.erase(state_to_remove.state_name)
	state_to_remove.transitioned.disconnect(_on_state_transitioned)


## Returns whether the State Machine has a state with the given name.
func has_state(state_name: String) -> bool:
	return states.has(state_name)


## Forces a state change to the given state name.
func change_state(new_state_name: String) -> void:
	var new_state := get_state(new_state_name)

	if not new_state:
		push_error("State '%s' does not exist in the state machine." % new_state_name)
		return

	_set_state(new_state)

func _notification(what: int) -> void:
	var triggers := [
		NOTIFICATION_READY,
		NOTIFICATION_CHILD_ORDER_CHANGED,
		NOTIFICATION_EDITOR_POST_SAVE,
	]

	if Engine.is_editor_hint() and what in triggers:
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []

	var state_children: Array[State] = []
	for child in get_children():
		if child is State:
			state_children.append(child)

	if state_children.size() == 0:
		warnings.append("StateMachine has no State children.")

	var state_names := {}
	var duplicates := ""

	for state in state_children:
		var this_name := state.state_name

		if state_names.has(this_name):
			duplicates += "- '%s'\n" % this_name
		else:
			state_names[this_name] = true

	if not duplicates == "":
		warnings.append("Duplicate state_name values detected:\n" + duplicates)

	return warnings


func _on_state_transitioned(this_state: State, new_state_name: String) -> void:
	if Engine.is_editor_hint():
		return

	if this_state != current_state:
		push_error("State transition signal received from a state that is not the current state.")
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