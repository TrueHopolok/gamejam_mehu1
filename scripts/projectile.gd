extends Node2D

@onready var dmg_area : Area2D = $PlayerDmgArea

var speed : float = 1
var damage : float = 1
var direction : Vector2 = Vector2(1, 1)

func hit(area : Area2D):
	if area.name == "HurtBox":
		queue_free()

func _ready():
	dmg_area.area_entered.connect(hit)
	direction *= speed

func _physics_process(_delta):
	print(name, global_position)
	global_position += direction
	if global_position.x < -16 or global_position.x > 336 or global_position.y < -16 or global_position.y > 196:
		queue_free()
