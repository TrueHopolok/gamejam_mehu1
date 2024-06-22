extends Button

func _pressed():
	get_tree().paused = false
	Global.load_game_over()
