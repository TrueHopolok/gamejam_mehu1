extends CanvasLayer

func _input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused: get_tree().paused = false
		else: 
			if get_tree().get_first_node_in_group("Player") == null: return
			else: get_tree().paused = true

func _process(delta):
	if get_tree().get_first_node_in_group("Player") == null: return
	visible = get_tree().paused
