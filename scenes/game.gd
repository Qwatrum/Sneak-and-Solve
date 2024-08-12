extends Control

var api_key : String = "no not for you!"
var url : String = "https://jamsapi.hackclub.dev/openai/chat/completions"
var temperature : float = 0.5
var max_tokens : int = 1024
var headers = ["Content-type: application/json", "Authorization: Bearer " + api_key]
var model : String = "gpt-3.5-turbo"
var messages = []
var request : HTTPRequest

var times_played
var max_times_played = 3
var password = "no-no-no-no"

var save_file_path = "user://save/"
var save_file_name = "DataSaver.tres"
var data = Data.new()

var t_response
var p_text
var t_response_node = preload("res://scenes/teachers_response.tscn")
var players_text_node = preload("res://scenes/players_text.tscn")

var start_dialogue = ["Welcome to Sneak & Solve! You are going to write an exam and you haven't learn! You prepared some cheats and hid them in some (weird) items. Your goal is to convince the teacher that you need this item. Click here to start!","Your prepared item is: ","Hello Micheal! I hope you studied for todays exam.", "Before I can let you in, I need to check your backpack.", "Let's see...", "What have I found? Why do you have "]
var dialoguing = true
var i = 0
var end = false
var items = ["an extra pencil", "a piano", "toilet paper", "a basketball", "a pair of sunglasses", "a glue stick", "a barcode scanner", "a toothbrush", "a ring", "a rubber duck", "a mop", "shampoo", "candy wrapper", "a cinder block", "sailboat toy", "tooth picks", "a towel", "a remote", "a screw", "a balloon", "a tissue box"]
var cheat_item

var allowed

func dir_absolute(path):
	DirAccess.make_dir_absolute(path)
	
func load_times_played():
	if FileAccess.file_exists(save_file_path + save_file_name):
		data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	else:
		save_times_played()
		load_times_played()
		
func save_times_played():
	ResourceSaver.save(data, save_file_path + save_file_name)

func _ready():
	dir_absolute(save_file_path)
	load_times_played()
	times_played = data.s_times_played
	
	
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)

	cheat_item = items.pick_random()
	t_response = t_response_node.instantiate()
	add_child(t_response)
	
	if times_played >= max_times_played:
		t_response.set_text("Unfortunately, you've reached the free limit.")
		start_dialogue = []
	else:
		t_response.set_text(start_dialogue[i])
		i+=1
	
func dialogue_request(dialogue):
	messages.append({
		"role": "user",
		"content": dialogue
		})
		
	var body = JSON.new().stringify({
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": model
	})
	
	var send_request = request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if send_request != OK:
		print("There was an error!")
		
	
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var message = response["choices"][0]["message"]["content"]
	display_teacher_response(message)
	
func next():
	
	if dialoguing:
		if i == 1:
			t_response.set_text(start_dialogue[i]+cheat_item)
		elif i == 2:
			$"Teacher".show()
			t_response.set_text(start_dialogue[i])
		elif i == 5:
			t_response.set_text(start_dialogue[i]+cheat_item+"?")
		else:
			if len(start_dialogue) != 0:
				t_response.set_text(start_dialogue[i])
			else:
				get_tree().change_scene_to_file("res://scenes/menu.tscn")
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
	
	times_played+=1
	data.change_times_played(times_played)
	save_times_played()
	
	p_text.queue_free()
	p_text = null
	
	t_response = t_response_node.instantiate()
	add_child(t_response)
	
	var prompt = "You are a teacher responsible for ensuring fairness during the upcoming exam. As part of your duties, you are checking the students' backpacks before the exam starts. You discover an item in Michael's backpack: "+cheat_item+". Michael must now convince you why he should be allowed to keep this item during the exam.\nIf Michael's explanation is exceptionally convincing and reasonable, respond with: true#<YOUR RESPONSE>\nIf his explanation is not convincing enough, respond with: false#<YOUR RESPONSE>\nDon't answer else! Sentimental reasons are not allowed as a justification. Students don't need to bring extra items.\nMichael: "+txt
	dialogue_request(prompt)
	
	
	
func display_teacher_response(txt):
	
	var answer_list = txt.split("#")
	
	var answer = answer_list
	if str(answer[0]).to_lower().begins_with("true") == false and str(answer[0]).to_lower().begins_with("false") == false:
		start_dialogue == ["Looks like there was an error. Please try again."]
		dialoguing = true
		end = true
		i = 0
	else:
		allowed = str(answer[0]).to_lower().begins_with("true")
		if len(answer) == 1:
			start_dialogue == ["Looks like there was an error. Please try again."]
			dialoguing = true
			end = true
			i = 0
		else:
			t_response.set_text(answer[1])
			if allowed:
				start_dialogue = ["You are allowed to enter the room. Good luck!"]
			else:
				start_dialogue = ["You are not allowed to enter. I will contact your parents!"]
			dialoguing = true
			i = 0
			end = true


func _on_reset_field_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		$"ResetField".hide()
		$"Teacher".hide()
		$"PasswordField".show()
		$"Reset".show()
		t_response.hide()


func _on_reset_button_down():
	
	var password_text = $"PasswordField".text
	$"Reset".hide()
	if password_text == password:
		
		$"PasswordField".text = "CORRECT"
		data.change_times_played(0)
		save_times_played()
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		
	else:
		$"PasswordField".text = "WRONG"
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
