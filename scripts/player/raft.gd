class_name Raft extends Node2D

@export var max_health : float = 20
@export var is_empty : bool = true

@onready var hurt_area : Area2D = $HurtArea

var health : float = 0
var building : Node2D = null

func die():
	# play death animation and destroy what is on top
	if building != null:
		building.queue_free()
	queue_free()

func injured(area : Area2D):
	if area.name == "DmgArea":
		health -= area.get_parent().damage
		if health <= 0.0: die()

func _ready():
	hurt_area.area_entered.connect(injured)
	health = max_health + Global.extra_raft_health
