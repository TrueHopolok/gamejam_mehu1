extends Node2D

signal died

@export var speed : float = 0.4
@export var prize : Array[int] = \
[0, 0, 0] 

@onready var catchable_area : Area2D = $CatchableArea

func catched(area : Area2D):
	if area.name == "CollectArea":
		for i in range(min(len(prize), len(Global.materials_amount))):
			Global.materials_amount[i] += prize[i]
		died.emit()
		queue_free()

func _ready():
	catchable_area.area_entered.connect(catched)

func _process(delta):
	# ANIMATION: swimming
	global_position.x -= speed
	if global_position.x <= -16: 
		died.emit()
		queue_free()
