extends Control

var api_key : String = "no-no-no Not for you"
var url : String = "https://api.openai.com/v1/chat/completions"
var temperature : float = 0.5
var max_tokens : int = 1024
var headers = ["Content-type: application/json", "Authorization: Bearer " + api_key]
var model : String = "gpt-3.5-turbo"
var messages = []
var request : HTTPRequest


var t_response
var p_text
var t_response_node = preload("res://scenes/teachers_response.tscn")
var players_text_node = preload("res://scenes/players_text.tscn")

var start_dialogue = ["Welcome to Sneak & Solve! You are going to write an exam and you haven't learn! You prepared some cheats and hid them in some (weird) items. Your goal is to convince the teacher that you need this item. Click here to start!","Your prepared item is: ","Hello Micheal! I hope you studied for todays exam.", "Before I can let you in, I need to check your backpack.", "Let's see...", "What have I found? Why do you have "]
var dialoguing = true
var i = 0
var end = false
var items = ["an extra pencil", "a piano", "toilet paper", "a basketball", "a pair of sunglasses", "a glue stick", "a barcode scanner", "a toothbrush", "a ring", "a rubber duck", "a mop", "shampoo"]
var cheat_item

var allowed


func _ready():
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)

	
	
	cheat_item = items.pick_random()
	t_response = t_response_node.instantiate()
	add_child(t_response)
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
	
	var prompt = "You are a teacher responsible for ensuring fairness during the upcoming exam. As part of your duties, you are checking the students' backpacks before the exam starts. You discover an item in Michael's backpack: "+cheat_item+". Michael must now convince you why he should be allowed to keep this item during the exam.\nIf Michael's explanation is exceptionally convincing and reasonable, respond with: true#<YOUR RESPONSE>\nIf his explanation is not convincing enough, respond with: false#<YOUR RESPONSE>\nMichael: "+txt
	dialogue_request(prompt)
	
	
func display_teacher_response(txt):
	
	#var example_return = "false#Your safety and well-being are very important, but bringing a mop to the exam is not necessary. If you're feeling overwhelmed or need help, please speak to me or another trusted adult. We're here to support you, but the mop won't be allowed during the exam."
	var answer_list = txt.split("#")
	
	var answer = answer_list
	
	allowed = str(answer[0]).to_lower().begins_with("true")
	
	t_response.set_text(answer[1])
	if allowed:
		start_dialogue = ["You are allowed to enter the room. Good luck!"]
	else:
		start_dialogue = ["You are not allowed to enter. I will contact your parents!"]
	dialoguing = true
	i = 0
	end = true
