extends KinematicBody
class_name BaseRayGun


export var damage = 0
export var force = 1
export var default_pos : Vector3
export var aim_pos : Vector3
export var aim_speed = 0.3
export var item : String
export var num_rays = 1
export var spread = 0.0 # larger number means more concentrated
export var max_aim = 1000

var muzzle = null #idfk how else to do this, f u godot.
var aiming = false
var multi_firing = false
var firing = false
var hitpos = Vector3.ZERO
var rays = []
var gun_user 
var head


func _ready():
	if num_rays > 1:
		rays.resize(num_rays)

func _physics_process(delta):
	aim()
	if firing:
		firing = false
		
		var from = head.global_transform.origin
		var to = head.transform.origin + (Vector3.FORWARD * max_aim)
		
		var space = get_world().direct_space_state
		var result = space.intersect_ray(from, to_global(to) , [self], 33, true, true)
		var hit_spot = Vector3.ZERO
		if result:
			var target = result.collider
			hit_spot = result.position
			if num_rays <= 1:
				if target.has_method('hit'):
					target.hit(damage, force, hit_spot, gun_user)
		else:
			hit_spot = to_global(to)
		if num_rays > 1:
				multi_firing = true
				hitpos = hit_spot
		else:
			gun_user = null
			hitpos = null
			head = null
	
	elif multi_firing:
		multi_firing = false
		var ray_positions = []
		ray_positions.resize(num_rays)
		print(head)
		print(hitpos)
		var local_pos =  head.to_local(hitpos)
		for i in num_rays:
			var pos = local_pos
			var blast_spread = (muzzle.global_transform.origin.distance_to(to_global(local_pos))) / spread
			pos.x += rand_range(-blast_spread, blast_spread)
			pos.z += 1
			pos.y += rand_range(-blast_spread, blast_spread)
			var space = get_world().direct_space_state
			var result = space.intersect_ray(head.global_transform.origin, to_global(pos), [self], 33, true, true)
			if result:
				rays[i] = result
		var total_damage = 0
		var total_force = 0
		var knock_back_point = Vector3.ZERO
		var hit
		for i in num_rays:
			if rays[i]:
				if rays[i].collider:
					hit = rays[i].collider
					if is_instance_valid(hit):
						if hit.has_method("hit"):
							total_damage += damage
							total_force += force
							knock_back_point += rays[i].position
				if is_instance_valid(hit):
					if hit.has_method('hit'):
						hit.hit(total_damage, total_force, knock_back_point, gun_user)
		gun_user = null
		hitpos = null
		head = null



func aim():
	if Input.is_action_pressed("aim"):
		transform.origin = transform.origin.linear_interpolate(aim_pos, aim_speed)
		aiming = true
	else:
		transform.origin = transform.origin.linear_interpolate(default_pos, aim_speed)
		aiming = false

func fire(user, pivot, type = "primary"):
	if aiming:
		if user.action:
			user.action.state == user.action.states.aim
			firing = true
			gun_user = user
			head = pivot

	else:
		if user.fsm:
			user.fsm.state == user.fsm.states.idle
