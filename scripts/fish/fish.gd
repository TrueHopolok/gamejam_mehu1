class_name Fish extends Node2D

signal died

@export_subgroup("Health Properties")
@export var max_health : float = 5
@export var hp_increase : float = 1.5

@export_subgroup("Attack Properties")
@export var damage : float = 1
@export var dmg_increase : float = 1.3

@export_subgroup("Extra Properties")
@export var min_distance : float = 10
@export var speed : float = 1.0
@export var prize : Array[int] = [0, 0, 0, 1]

@onready var dmg_collider : CollisionShape2D = $DmgArea/DmgBox
@onready var hurt_area : Area2D = $HurtArea
@onready var health_bar : ProgressBar = $HealthBar
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D

var is_attacking : bool = false
var target : Node2D = null
var prev_direction : int = 1
var velocity : Vector2
var health : float = 0

func find_target():
	for element in get_tree().get_nodes_in_group("ENTITY_allies"):
		if target == null: target = element
		elif global_position.distance_squared_to(target.global_position) > \
			global_position.distance_squared_to(element.global_position):
			target = element

func attack():
	animated_sprite_2d.play("attack")
	is_attacking = true
	dmg_collider.disabled = false

func die():
	for i in range(min(len(prize), len(Global.materials_amount))):
		Global.materials_amount[i] += prize[i]
	died.emit()
	queue_free()

func injured(area : Area2D):
	if area.name == "PlayerDmgArea":
		health -= area.get_parent().damage
		health_bar.value = (clampf(health, 0, max_health)) * 100 / max_health
		if health <= 0.0: die()

func swim():
	animated_sprite_2d.play("swim")
	find_target()
	if target == null: return
	velocity = global_position.direction_to(target.global_position) * speed
	var direction = sign(global_position.direction_to(target.global_position).x)
	if direction != 0 and prev_direction != direction:
		prev_direction = - prev_direction
		apply_scale(Vector2(-1, 1))
		if prev_direction == 1: health_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
		else: health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	if global_position.distance_squared_to(target.global_position) > int(min_distance * min_distance):
		global_position.x = global_position.x + velocity.x
		global_position.y = global_position.y + velocity.y
	else: attack()

func _ready():
	hurt_area.area_entered.connect(injured)
	
	find_target()
	
	if target == null: prev_direction = 1
	else: 
		prev_direction = sign(global_position.direction_to(target.global_position).x)
		if prev_direction == 0: prev_direction = 1
	apply_scale(Vector2(prev_direction, 1))
	if prev_direction == 1: health_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
	else: health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	
	if int(Global.waves_completed / 5) != 0:
		max_health += 0.5 * pow(hp_increase, int(Global.waves_completed / 5) - 1) 
		damage += 0.5 * pow(dmg_increase, int(Global.waves_completed / 5) - 1) 
	health = max_health

func _process(_delta):
	if is_attacking: 
		dmg_collider.disabled = true
		is_attacking = animated_sprite_2d.is_playing()
		return
	swim()
