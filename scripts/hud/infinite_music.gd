extends AudioStreamPlayer

func _physics_process(_delta):
	if not playing: play()
