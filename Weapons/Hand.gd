extends Spatial

var item_to_grab = null
var item_to_drop = null

func grab(aimcast, dir):
	if aimcast.is_colliding():
		if get_children():
			if get_child(0).is_in_group("weapons"):
				drop(dir)
		item_to_grab = aimcast.get_collider()
		var item = load(item_to_grab.in_hand)
		var grab = item.instance()
		add_child(grab) 
		item_to_grab.queue_free()
		item_to_grab = null


func drop(dir):
	if get_children():
		if get_child(0).is_in_group("weapons"):
			item_to_drop = get_child(0)
			var item_PS = load(item_to_drop.item)
			var item = item_PS.instance()
			get_tree().root.add_child(item)
			item.global_transform.origin = item_to_drop.muzzle.global_transform.origin
			item.throw(dir)
			item_to_drop.queue_free()
			print(item_to_drop)
			item_to_drop = null
