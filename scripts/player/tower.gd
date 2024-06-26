class_name Tower extends Node2D

@export var projectile_damage : float = 1
@export var projectile_speed : float = 6
@export var projectile_prefab : PackedScene = null
@export var reload_time : int = 90

@onready var spawn_marker : Marker2D = $SpawnMarker
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var main = get_tree().get_first_node_in_group("SCENE_main")

var target : Node2D = null
var prev_direction : int = 1
var current_reload : int = 0

func find_target():
	for element in get_tree().get_nodes_in_group("ENTITY_enemy"):
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

func _process(_delta):
	if animated_sprite_2d.frame == 5: animated_sprite_2d.play("idle")
	find_target()
	if current_reload > 0: current_reload -= 1
	if target == null: return
	var direction = global_position.direction_to(target.global_position)
	if direction.x != 0 and prev_direction != sign(direction.x): 
		prev_direction = - prev_direction
		apply_scale(Vector2(-1, 1))
	if current_reload > 0: return
	current_reload = reload_time
	if main == null: return
	var instance = projectile_prefab.instantiate()
	if animated_sprite_2d.animation == "idle": animated_sprite_2d.set_animation("attack")
	main.add_child(instance)
	instance.global_position = spawn_marker.global_position
	instance.damage = projectile_damage + Global.extra_projectile_damage
	instance.direction = direction * projectile_speed
