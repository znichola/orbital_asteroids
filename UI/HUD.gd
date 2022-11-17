tool
extends CanvasLayer

signal start_game


func _ready():
	$control.connect("resized", self, "center")
	
	center()
	pass

func _input(event):
	if global.HOME_SCREEN and Input.is_action_pressed("ui_accept"):
		$message_timer.start()
		show_message("GO", 1.5)
		#$message_timer.start()
		emit_signal("start_game")
		global.HOME_SCREEN = false
		#print($message_timer.time_left, $message_timer.is_stopped())
	pass
	if Input.is_action_just_pressed("center"):
		center()
	# pause code

func update_score(val):
	$center/score_label.text = str(val)

func update_lives(val):
	$lives_label.text = str(val)
	
func show_message(text, time):
	$center/message_lable.text = text
	$center/message_lable.show()
	if time > 0:
		$message_timer.wait_time = time
		$message_timer.start()

func start_game():
	show_message("Eliminate the\nAsteroids", 0)

	#print($message_timer.time_left, $message_timer.is_stopped())
	global.HOME_SCREEN = true
	pass

func show_game_over():
	show_message("Game Over", 0)
#	yield($message_timer, "timeout")
#	start_game()
	#show_message("Eliminate the\nAsteroids")
	#$message_lable.text = "Eliminate the\nAsteroids"
	#$message_lable.show()

func _on_message_timer_timeout():
#	print($message_timer.time_left, $message_timer.is_stopped())
	if not global.HOME_SCREEN:
		$center/message_lable.hide()
#		print("hide")
	#pass # replace with function body

func center():
	print("centering")
	#get_sctetch_ratio()
	#$center.margin_right = get_viewport().size.x
	$center.margin_right = get_viewport().get_visible_rect().size.x
	#print(get_viewport().get_size_override())
	#print(get_viewport().get_visible_rect().size.x)
	#print(get_viewport().size - get_viewport().get_visible_rect().size) 
	print(get_viewport().get_final_transform().get_scale()) # this gives the scale factor applied to everyting

	#$center/message_lable.rect_scale = Vector2(1,1) / get_viewport().get_final_transform().get_scale() #- Vector2(1,1)
	