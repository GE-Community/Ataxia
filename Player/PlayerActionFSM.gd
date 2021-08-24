extends StateMachine


func _ready():
	add_state("none")
	add_state("aim")
	call_deferred("set_state", states.none)

func _state_logic(delta):
	pass

func _get_transition(delta):
	match state:
		states.none:
			if Input.is_action_pressed("aim"):
				return states.aim
		states.aim:
			if !Input.is_action_pressed("aim"):
				return states.none
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.none:
			pass
		states.aim:
			parent.is_gravity = true


func _exit_state(old_state, new_state):
	match old_state:
		states.none:
			pass
		states.aim:
			pass
