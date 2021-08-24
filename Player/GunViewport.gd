extends Viewport

func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	size = OS.get_screen_size()



func _on_viewport_size_changed():
	size = OS.get_screen_size()
