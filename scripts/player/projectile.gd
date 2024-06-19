extends Node2D

@onready var dmg_area : Area2D = $PlayerDmgArea

var is_fine : bool = true
var damage : float = 1
var direction : Vector2 = Vector2(1, 1)

func hit(area : Area2D):
	if area.name == "HurtArea":
		if is_fine: is_fine = false
		else: queue_free()

func _ready():
	dmg_area.area_entered.connect(hit)

func _process(_delta):
	global_position += direction
	if global_position.x < -16 or global_position.x > 336 or global_position.y < -16 or global_position.y > 196:
		queue_free()
