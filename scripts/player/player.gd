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
@export var max_health : int = 3
@export var regen_time : int = 150
@export var invincability_time : int = 30
@export var drowning_time : int = 300

@export_subgroup("Attack Properties")
@export var basic_damage : float = 0.5
@export var attack_reload : int = 20
@export var basic_attack_size : float = 1.0

@export_subgroup("Extra Properties")
@export var speed : float = 1
@export var placeables : Array[PackedScene]
@export var place_costs : Array[Array]
@export var min_place_distance : float = 400

@onready var dmg_collider : CollisionShape2D = $PlayerDmgArea/PlayerDmgBox
@onready var hurt_area : Area2D = $HurtArea
@onready var water_area : Area2D = $WaterArea
@onready var place_area : Area2D = $PlaceArea

@onready var water_bar : ProgressBar = $DrowningBar
@onready var health_bar : ProgressBar = $HealthBar

@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite_splash : AnimatedSprite2D = $AnimatedSpriteSplash

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
	# ANIMATION: play death animation and end game
	Global.load_game_over()
	queue_free()

func injured(area : Area2D):
	if current_invicability > 0:
		return
	if area.name == "DmgArea":
		# ANIMATION: play damage animation (make player red)
		health -= 1
		current_regen = regen_time
		current_invicability = invincability_time
		if health <= 0: die()

func attack():
	if current_reload > 0: return
	if durability > 0:
		durability -= 1
		dmg_collider.scale.x = attack_size
		damage = weapon_damage
		if durability <= 0:
			# ANIMATION: show hand as a weapon through global
			pass
	else:
		dmg_collider.scale.x = 1
		damage = basic_damage
	dmg_collider.disabled = false
	current_reload = attack_reload
	damage += Global.extra_melee_damage

func _input(event):
	if not event is InputEventMouseButton: return
	if not event.button_index == MOUSE_BUTTON_RIGHT: return
	if not event.is_pressed(): return
	for i in range(min(len(Global.materials_amount), len(place_costs[current_placeable]))):
		if Global.materials_amount[i] < place_costs[current_placeable][i]:
			return
	var place_pos : Vector2 = get_viewport().get_mouse_position()
	if place_pos.distance_squared_to(global_position) > min_place_distance: return
	if place_pos.x < border_left or place_pos.x > border_right: return
	if place_pos.y < border_top or place_pos.y > border_bottom: return
	place_area.global_position = place_pos
	var instance : Node2D = placeables[current_placeable].instantiate()
	if current_placeable != 3:
		if len(place_area.get_overlapping_areas()) > 0: return
	else:
		var is_possible : bool = false
		for area in place_area.get_overlapping_areas():
			var parent = area.get_parent()
			if not is_instance_of(parent, Raft): continue
			if parent.is_empty:
				parent.is_empty = false
				parent.building = instance
				is_possible = true
				break
		if not is_possible: return
	var main: Node2D
	for element in get_tree().get_root().get_children():
		if element.name == "Main":
			main = element
			break
	main.add_child(instance)
	instance.global_position = place_pos
	for i in range(min(len(Global.materials_amount), len(place_costs[current_placeable]))):
		Global.materials_amount[i] -= place_costs[current_placeable][i]
	

func _ready():
	health = max_health
	hurt_area.area_entered.connect(injured)
	dmg_collider.disabled = true
	animated_sprite_splash.play("default")

func _physics_process(_delta):
	if health <= 0: return
	
	is_on_ground = len(water_area.get_overlapping_areas()) > 0
	if is_on_ground: current_drowning = 0
	else: 
		current_drowning += 1
		if current_drowning >= drowning_time:
			# ANIMATION: play damage animation (make player red)sss
			health -= 1
			current_regen = regen_time
			current_drowning = 0
			if health <= 0: die()
	water_bar.visible = not is_on_ground
	water_bar.value = current_drowning * 100 / drowning_time
	
	if current_reload > 0:
		current_reload -= 1
		dmg_collider.disabled = true
	if current_invicability > 0:
		current_invicability -= 1
	
	if health < max_health and is_on_ground:
		current_regen -= 1
		if current_regen <= 0:
			# ANIMATION: play healing animation (make him green)
			health += 1
			current_regen = regen_time
	health_bar.visible = max_health > health
	health_bar.value = health * 100 / max_health
	
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
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !is_splash_animation: animated_sprite_splash.play("default")
		is_splash_animation = true
		attack()
	else:
		animated_sprite_splash.stop()
		animated_sprite_splash.frame = 0
		is_splash_animation = false
	
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	if velocity.length_squared() == 0:
		if is_on_ground:	
			if is_splash_animation: animated_sprite_2d.play("idle_attack")
			else: animated_sprite_2d.play("idle")
		else:
			if is_splash_animation: animated_sprite_2d.play("swim_attack")	
			else: animated_sprite_2d.play("swim_idle")
		pass
	else:
		if is_on_ground:
			if is_splash_animation: animated_sprite_2d.play("run_attack")
			else: animated_sprite_2d.play("run")
		else:
			if is_splash_animation: animated_sprite_2d.play("swim_attack")	
			else: animated_sprite_2d.play("swim_run")	
		pass
	global_position.x = clampf(global_position.x + velocity.x, border_left, border_right)
	global_position.y = clampf(global_position.y + velocity.y, border_top, border_bottom)
