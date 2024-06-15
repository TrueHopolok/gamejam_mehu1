class_name Fish extends Node2D

signal died

@export_subgroup("Health Properties")
@export var max_health : float = 5
@export var hp_increase : float = 1.5

@export_subgroup("Attack Properties")
@export var damage : float = 1
@export var dmg_increase : float = 1.3
@export var reload_time : int = 20

@export_subgroup("Extra Properties")
@export var min_distance : float = 10
@export var speed : float = 0.5

@onready var dmg_collider : CollisionShape2D = $DmgArea/DmgBox
@onready var hurt_area : Area2D = $HurtArea
@onready var health_bar : ProgressBar = $HealthBar

var current_reload : int = 0
var target : Node2D = null
var prev_direction : int = 1
var velocity : Vector2
var attackable_objects : Array = [Player, Raft]
var health : float = 0

func find_target():
	for main in get_tree().get_root().get_children():
		for element in main.get_children():
			for name in attackable_objects:
				if is_instance_of(element, name):
					if target == null: target = element
					elif global_position.distance_squared_to(target.global_position) > \
						global_position.distance_squared_to(element.global_position):
						target = element

func attack_start():
	if current_reload <= 0:
		# ANIMATION: attack
		dmg_collider.disabled = false
		current_reload = reload_time
	elif current_reload < reload_time >> 1:
		dmg_collider.disabled = true
	current_reload -= 1

func attack_stop():
	dmg_collider.disabled = true
	current_reload = 0

func die():
	# ANIMATION: death
	died.emit()
	queue_free()

func injured(area : Area2D):
	if area.name == "PlayerDmgArea":
		health -= area.get_parent().damage
		health_bar.value = (clampf(health, 0, max_health)) * 100 / max_health
		if health <= 0.0: die()

func _ready():
	find_target()
	prev_direction = sign(global_position.direction_to(target.global_position).x)
	if prev_direction == 0: prev_direction = 1
	apply_scale(Vector2(prev_direction, 1))
	if prev_direction == 1: health_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
	else: health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	hurt_area.area_entered.connect(injured)
	if int(Global.info_wave / 5)  != 0:
		max_health += 0.5 * pow(hp_increase, int(Global.info_wave / 5) - 1) 
		damage += 0.5 * pow(dmg_increase, int(Global.info_wave / 5) - 1) 
	health = max_health

func _physics_process(_delta):
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
		# ANIMATION: move
		attack_stop()
		global_position.x = global_position.x + velocity.x
		global_position.y = global_position.y + velocity.y
	else: attack_start()
