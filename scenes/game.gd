extends Control

var t_response



func next():
	if t_response:
		t_response.queue_free()
