extends StateMachine

var stop_speed = 0.2

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent.state_debug.text = "State = " + str(states.keys()[state])
	parent.run_button() #this handles not moving when aiming in it's own function
	if parent.action.state == parent.action.states.aim: #this is stuff you can do when aiming
		pass
	else: #this is stuff you can do when not aiming
		parent._handle_jump(delta)
		parent._handle_input()
	#these I want to happen even when aiming or not.
	parent._apply_velocity()
	parent._apply_gravity(delta)
	parent.movement(delta)
	parent.shoot()
	parent.handle_pickup()

func _get_transition(delta):
	match state:
		states.idle:
			if parent.action.state != parent.action.states.aim:
					if !parent.grounded:
						if parent.velocity.y > 0:
							return states.jump
						elif parent.velocity.y < 0:
							return states.fall
					elif (abs(parent.velocity.x) + abs(parent.velocity.z)) > stop_speed:
						return states.run
		states.run:
			if !parent.grounded:
				if parent.velocity.y > 0:
					return states.jump
				elif parent.velocity.y < 0:
					return states.fall
			elif (abs(parent.velocity.x) + abs(parent.velocity.z)) < stop_speed:
				return states.idle
		states.jump:
			if parent.grounded:
				return states.idle
			elif parent.velocity.y < 0:
				return states.fall
		states.fall:
			if parent.grounded:
				return states.idle
			elif parent.velocity.y >= 0:
				return states.jump

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			pass
		states.run:
			pass
		states.jump:
			pass
		states.fall:
			pass

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			pass
		states.run:
			pass
		states.jump:
			pass
		states.fall:
			pass

