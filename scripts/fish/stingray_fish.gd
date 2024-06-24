extends Fish

func attack():
	target.queue_free()
	die()

func find_target():
	if target != null: return
	var tmp : Marker2D = Marker2D.new()
	get_tree().get_first_node_in_group("SCENE_main").add_child(tmp)
	tmp.global_position = Vector2(330 - global_position.x, global_position.y)
	target = tmp

func _ready():
	hurt_area.area_entered.connect(injured)
	prev_direction = 1
	apply_scale(Vector2(prev_direction, 1))
	if prev_direction == 1: health_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
	else: health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	
	if int(Global.waves_completed / 5) != 0:
		max_health += 0.5 * pow(hp_increase, int(Global.waves_completed / 5) - 1) 
		damage += 0.5 * pow(dmg_increase, int(Global.waves_completed / 5) - 1) 
	health = max_health

func _process(_delta):
	dmg_collider.disabled = not dmg_collider.disabled
	swim()
