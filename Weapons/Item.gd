extends RigidBody
class_name Item

export var in_hand : String

func throw(dir):
	apply_central_impulse(dir)
