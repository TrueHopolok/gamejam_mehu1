extends Fish

@onready var hurt_collider : CollisionShape2D = $HurtArea/HurtBox 

func attack():
	super()
	hurt_collider.scale = Vector2(1, 1)

func _process(_delta):
	if is_attacking:
		dmg_collider.disabled = not dmg_collider.disabled
		return
	swim()
