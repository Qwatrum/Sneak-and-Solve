extends Panel

@onready var game := get_parent()

func set_text(txt):
	$"Text".text = txt


func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		game.next()
