extends ParallaxBackground

func _process(delta):
	scroll_base_offset -= Vector2(50, 0) * delta
