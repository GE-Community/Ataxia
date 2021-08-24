
extends CanvasLayer


func _ready():
	set_visible(false)

func _input(event):
	if event.is_action_pressed("pause"): # escape button by default
		set_visible(!get_tree().paused) # if not pause then hide
		get_tree().paused = !get_tree().paused # toggle pause status


func _on_Continue_pressed():
	get_tree().paused = false
	set_visible(false)

	
func set_visible(is_visible):
	if is_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for node in get_children():
		node.visible = is_visible


func _on_Restart_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
	set_visible(false)


func _on_Quit_pressed():
	get_tree().quit()
