extends CanvasLayer

func _process(delta):
	visible = get_tree().get_first_node_in_group("Player") == null
	if visible: get_tree().paused = true
