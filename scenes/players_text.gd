extends LineEdit

@onready var game := get_parent()


func _on_say_button_down():
	game.player_says(text)
