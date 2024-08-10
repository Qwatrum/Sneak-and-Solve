extends Control

var t_response
var p_text
var t_response_node = preload("res://scenes/teachers_response.tscn")
var players_text_node = preload("res://scenes/players_text.tscn")

var start_dialogue = ["Welcome to Sneak & Solve! You are going to write an exam and you haven't learn! You prepared some cheats and hid them in some (weird) items. Your goal is to convince the teacher that you need this item. Click here to start!","Hello Micheal! I hope you studied for todays exam.", "Before I can let you in, I need to check your backpack.", "Let's see...", "What have I found? Why do you have "]
var dialoguing = true
var i = 0
var end = false
var cheat_item = "an extra pencil"

var allowed

func _ready():
	t_response = t_response_node.instantiate()
	add_child(t_response)
	t_response.set_text(start_dialogue[i])
	i+=1
	


func next():
	if dialoguing:
		if i == 1:
			$"Teacher".show()
		if i == 4:
			t_response.set_text(start_dialogue[i]+cheat_item+"?")
		else:
			t_response.set_text(start_dialogue[i])
		i+=1
		if i == len(start_dialogue):
			dialoguing = false
	else:
		t_response.queue_free()
		t_response = null
		if not end:
			p_text = players_text_node.instantiate()
			add_child(p_text)
			
		if end and allowed:
			$"Win".show()
		elif end and not allowed:
			$"Loose".show()
		
func player_says(txt):
	p_text.queue_free()
	p_text = null
	
	t_response = t_response_node.instantiate()
	add_child(t_response)
	var answer = create_teacher_response(txt)
	#print(answer)
	allowed = str(answer[0]).to_lower().begins_with("true")
	#print(allowed)
	t_response.set_text(answer[1])
	if allowed:
		start_dialogue = ["You are allowed to enter the room."]
	else:
		start_dialogue = ["You are not allowed to enter. I will contact your parents!"]
	dialoguing = true
	i = 0
	end = true
	
func create_teacher_response(txt):
	# TODO Here must go AI stuff
	var prompt = ""
	var example_return = "true#That sounds good."
	var answer_list = example_return.split("#")
	return answer_list
