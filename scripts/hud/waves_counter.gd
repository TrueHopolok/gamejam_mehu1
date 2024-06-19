extends Label

func _process(_delta):
	var extra : int
	if Global.fishes_alive > 0:
		extra = 1
	else:
		extra = 0
	text = "Wave " + str(Global.waves_completed + extra)
