extends Control


func _on_play_button_down():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_credits_button_down():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_informations_button_down():
	get_tree().change_scene_to_file("res://scenes/informations.tscn")
