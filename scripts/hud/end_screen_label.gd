extends Label

func _process(delta):
	text = "Waves survived: " + str(Global.waves_completed) + \
		   "\nFishes killed: "  + str(Global.fishes_killed)
