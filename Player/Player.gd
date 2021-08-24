extends KinematicBody

signal health_updated(health)
signal killed()

onready var pivot = $Pivot
onready var ground_raycasts = $GroundRaycasts
onready var fsm = $FSM
onready var state_debug = $HUD/Debug/State
onready var health = max_health setget _set_health
onready var i_frames = $I_Frames
onready var hud_anim = $HUD/AnimationPlayer
onready var effects_anim = $EffectsAnimation
onready var action = $PlayerActionFSM
onready var camera = $Pivot/Camera
onready var hand = $Pivot/Hand
onready var grab_cast = $Pivot/GrabCast

export var gravity = -40.0
export var walk_speed = 8.0
export var run_speed = 16.0
export var jump_speed = 10.0
export var mouse_sensitivity = 0.002
export var acceleration = 4.0
export var friction = 6.0
export (float) var max_health = 100



var dir = Vector3.ZERO
var velocity = Vector3.ZERO
var grounded = false
var is_gravity = true
var speed = 0
var drop_speed = 5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	speed = walk_speed

func damage(amount):
	if i_frames.is_stopped():
		_set_health(health-amount)

func kill():
	get_tree().reload_current_scene()

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	if health != prev_health:
		hud_anim.play("DamageFlash")
		emit_signal("health_updated", health)
		if health == 0:
			kill()

func hit(damage, force, user):
	damage(damage)


func _apply_gravity(delta):
	if is_gravity:
		velocity.y += gravity * delta


func shoot():
	if hand.get_children():
		if Input.is_action_just_pressed("shoot"):
			hand.get_child(0).fire(self, pivot)
	else:
		if Input.is_action_just_pressed("shoot"):
			hand.grab(grab_cast, -transform.basis.z*drop_speed)

func _handle_jump(delta):
	grounded = _check_if_grounded(ground_raycasts)
	
	if grounded:
		#this prevents you from sliding without messing up the is_on_ground() check
		velocity.y += gravity * delta / 100.0
		is_gravity = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
	else:
		is_gravity = true

func current_weapon():
	if hand.get_children():
		return hand.get_child(0)

func run_button():
	if action.state != action.states.aim:
		if Input.is_action_pressed("run"):
			speed = run_speed
		elif !Input.is_action_pressed("run"):
			speed = walk_speed
	else:
		speed = 0

func handle_pickup():
	if Input.is_action_just_pressed("interact"):
		hand.grab(grab_cast, -transform.basis.z*drop_speed)
	if Input.is_action_just_pressed("drop"):
		hand.drop(-transform.basis.z*drop_speed)

func _handle_input():
	dir = Vector3.ZERO
	var basis = transform.basis
	if Input.is_action_pressed("move_forward"):
		dir -= basis.z
	if Input.is_action_pressed("move_back"):
		dir += basis.z
	if Input.is_action_pressed("move_left"):
		dir -= basis.x
	if Input.is_action_pressed("move_right"):
		dir += basis.x
	dir = dir.normalized()

func movement(delta):
	var hvel = velocity
	hvel.y = 0.0
	var target = dir * speed
	var accel
	if dir.dot(hvel) > 0.0:
		accel = acceleration
	else:
		accel = friction
	hvel = hvel.linear_interpolate(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z

func zoom(zoom_fov):
	camera.fov = lerp(camera.fov, zoom_fov, current_weapon().aim_speed)

func _apply_velocity():
	velocity = move_and_slide(velocity, Vector3.UP, true)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.5, 1.5)

func _check_if_grounded(raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	
	return false






func _on_I_Frames_timeout():
	effects_anim.play("None")


func _on_HUD_animation_finished(anim_name):
	if anim_name == "DamageFlash":
		i_frames.start()
		effects_anim.play("Invincible")
