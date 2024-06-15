extends Node2D

@export var projectile_damage : float = 1
@export var projectile_speed : float = 1.2
@export var projectile_prefab : PackedScene = null
@export var reload_time : int = 90

@onready var spawn_marker : Marker2D = $SpawnMarker

var target : Node2D = null
var attackable_objects = [Fish]
var prev_direction : int = 1
var current_reload : int = 0

func find_target():
	for main in get_tree().get_root().get_children():
		for element in main.get_children():
			for name in attackable_objects:
				if is_instance_of(element, name):
					if target == null: target = element
					elif global_position.distance_squared_to(target.global_position) > \
						global_position.distance_squared_to(element.global_position):
						target = element	

func _ready():
	current_reload = reload_time
	find_target()
	if target == null: prev_direction = 1
	else: prev_direction = sign(global_position.direction_to(target.global_position).x)
	if prev_direction == 0: prev_direction = 1
	apply_scale(Vector2(prev_direction, 1))

func _physics_process(_delta):
	find_target()
	if current_reload > 0: current_reload -= 1
	if target == null: return
	var direction = global_position.direction_to(target.global_position)
	if direction.x != 0 and prev_direction != sign(direction.x): 
		prev_direction = - prev_direction
		apply_scale(Vector2(-1, 1))
	if current_reload > 0: return
	current_reload = reload_time
	var instance = projectile_prefab.instantiate()
	instance.global_position = spawn_marker.global_position
	instance.speed = projectile_speed
	instance.damage = projectile_damage
	instance.direction = direction
	add_child(instance)
