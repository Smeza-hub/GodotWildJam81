class_name FiniteStateMachine
extends Node

@export var state: State

func _ready():
	await get_tree().create_timer(0.5).timeout
	change_state(state)

func change_state(new_state: State):
		if state is State:
			state._exit_state()
		new_state._enter_state()
		state = new_state
		print(state)
