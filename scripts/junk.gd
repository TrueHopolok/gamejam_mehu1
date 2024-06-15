extends Node2D

signal collected

@export var speed : float = 0.4

@onready var catchable_area : Area2D = $CatchableArea

func catched(area : Area2D):
	if is_instance_of(area.get_parent(), Player):
		collected.emit()
		queue_free()

func _ready():
	catchable_area.area_entered.connect(catched)

func _process(delta):
	# ANIMATION: swimming
	global_position.x -= speed
	if global_position.x <= -16: queue_free()
