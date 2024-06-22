class_name Player extends Node2D

@export_subgroup("Weapon Properties")
@export var weapon_damage : float = 0.5
@export var durability : int = 0
@export var max_durability : int = 0
@export var attack_size : float = 1

@export_subgroup("Game Area Borders")
@export var border_top : int = 12
@export var border_bottom : int = 18+16*9+6
@export var border_left : int = 32
@export var border_right : int = 32+16*13

@export_subgroup("Health Properties")
@export var max_health : int = 4
@export var regen_time : int = 300
@export var invincability_time : int = 45
@export var drowning_time : int = 300

@export_subgroup("Attack Properties")
@export var basic_damage : float = 0.5
@export var attack_reload : int = 20
@export var basic_attack_size : float = 1.0

@export_subgroup("Extra Properties")
@export var speed : float = 2.0
@export var placeables : Array[PackedScene]
@export var place_costs : Array[Array]
@export var min_place_distance : float = 400
@export var color_time : int = 20

@onready var dmg_collider : CollisionShape2D = $PlayerDmgArea/PlayerDmgBox
@onready var hurt_area : Area2D = $HurtArea
@onready var water_area : Area2D = $WaterArea
@onready var place_area : Area2D = $PlaceArea

@onready var water_bar : ProgressBar = $DrowningBar
@onready var health_bar : ProgressBar = $HealthBar

@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_splash : AnimatedSprite2D = $AnimatedSpriteSplash

@onready var main = get_tree().get_first_node_in_group("SCENE_main")

var current_color : int = 0
var damage : float
var velocity : Vector2
var prev_direction : int = 1
var health : int = 0
var current_invicability : int = 0
var current_regen : int = 0
var current_drowning : int = 0
var current_reload : int = 0
var attacking : bool = false
var is_on_ground : bool = false
var is_splash_animation : bool = false
var current_placeable : int = 0

func die():
	queue_free()

func damaged(damage_color : Color):
	var audio : AudioStreamPlayer = get_tree().get_first_node_in_group("SFX_damage")
	if audio != null: audio.play()
	animated_sprite_2d.modulate = damage_color
	health -= 1
	current_color = color_time
	current_regen = regen_time
	current_invicability = invincability_time
	if health <= 0: die()

func injured(area : Area2D):
	if current_invicability > 0:
		return
	if area.name == "DmgArea":
		damaged(Color(1, 0, 0))

func attack():
	if current_reload > 0: return
	if durability > 0:
		durability -= 1
		dmg_collider.scale.x = attack_size
		damage = weapon_damage
	else:
		dmg_collider.scale.x = 1
		damage = basic_damage
	dmg_collider.disabled = false
	current_reload = attack_reload
	damage += Global.extra_melee_damage

func place():
	for i in range(min(len(Global.materials_amount), len(place_costs[current_placeable]))):
		if Global.materials_amount[i] < place_costs[current_placeable][i]:
			return
	var place_pos : Vector2 = place_area.global_position
	if place_pos.distance_squared_to(global_position) > min_place_distance: 
		return
	if place_pos.x < border_left or place_pos.x > border_right: 
		return
	if place_pos.y < border_top or place_pos.y > border_bottom: 
		return
	if main == null: return
	var instance : Node2D = placeables[current_placeable].instantiate()
	main.add_child(instance)
	instance.global_position = place_pos
	if current_placeable != 3:
		if len(place_area.get_overlapping_areas()) > 0:
			instance.queue_free()
			return
	if current_placeable == 3:
		var is_possible : bool = false
		for area in place_area.get_overlapping_areas():
			var parent = area.get_parent()
			if not is_instance_of(parent, Raft): continue
			if parent.is_empty:
				parent.is_empty = false
				parent.building = instance
				instance.global_position = parent.global_position
				is_possible = true
				break
		if not is_possible: 
			instance.queue_free()
			return
	for i in range(min(len(Global.materials_amount), len(place_costs[current_placeable]))):
		Global.materials_amount[i] -= place_costs[current_placeable][i]
	

func _ready():
	health = max_health
	hurt_area.area_entered.connect(injured)
	dmg_collider.disabled = true
	animated_sprite_splash.play("default")

func _process(_delta):
	if health <= 0: return
	
	## COLOR RESET ##
	if current_color > 0: 
		current_color -= 1
		if current_color == 0: animated_sprite_2d.modulate = Color(1, 1, 1)
	
	## PLATFORM / DROWNING CHECK ##
	is_on_ground = len(water_area.get_overlapping_areas()) > 0
	if is_on_ground: current_drowning = 0
	else: 
		current_drowning += 1
		if current_drowning >= drowning_time:
			current_drowning = 0
			damaged(Color(0, 0.4, 1))
	## DROWNING BAR ##
	water_bar.visible = not is_on_ground
	water_bar.value = current_drowning * 100 / drowning_time
	
	## ATTACK RELOAD ##
	if current_reload > 0:
		current_reload -= 1
		dmg_collider.disabled = true
		
	## INVINCABILITY TIMER ##
	if current_invicability > 0:
		current_invicability -= 1
	
	##  HEALTH REGENERATION ##
	if health < max_health and is_on_ground:
		current_regen -= 1
		if current_regen <= 0:
			animated_sprite_2d.modulate = Color(0, 1, 0)
			health += 1
			current_color = color_time
			current_regen = regen_time
	health_bar.visible = max_health > health
	health_bar.value = (health - 1) * 25
	
	## FACING DIRECTION ##
	var direction = sign(global_position.direction_to(get_viewport().get_mouse_position()).x)
	if direction != 0 and prev_direction != direction:
		prev_direction = - prev_direction
		apply_scale(Vector2(-1, 1)) 
		if prev_direction == 1: 
			water_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
			health_bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END
		else: 
			water_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
			health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	
	## ATTACK ACTIVATION ##
	if Input.is_action_pressed("attack"):
		if !is_splash_animation: animated_sprite_splash.play("default")
		is_splash_animation = true
		attack()
	else:
		animated_sprite_splash.stop()
		animated_sprite_splash.frame = 0
		is_splash_animation = false
	
	## PLACE ACTIVATION ##
	if Input.is_action_pressed("build"):
		place()
	
	## MOVEMENT ##
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	if velocity.length_squared() == 0:
		if is_on_ground:	
			if is_splash_animation: animated_sprite_2d.play("idle_attack")
			else: animated_sprite_2d.play("idle")
		else:
			if is_splash_animation: animated_sprite_2d.play("swim_attack")	
			else: animated_sprite_2d.play("swim_idle")
	else:
		if is_on_ground:
			if is_splash_animation: animated_sprite_2d.play("run_attack")
			else: animated_sprite_2d.play("run")
		else:
			if is_splash_animation: animated_sprite_2d.play("swim_attack")	
			else: animated_sprite_2d.play("swim_run")	
	global_position.x = clampf(global_position.x + velocity.x, border_left, border_right)
	global_position.y = clampf(global_position.y + velocity.y, border_top, border_bottom)
