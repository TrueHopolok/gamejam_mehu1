class_name Player extends Node2D

@export_subgroup("Weapon Properties")
@export var damage : float = 0.5
@export var current_range : float = 1
@export var durability : int = 0

@export_subgroup("Game Area Borders")
@export var border_top : int = 12
@export var border_bottom : int = 18+16*9+6
@export var border_left : int = 32
@export var border_right : int = 32+16*13

@export_subgroup("Health Properties")
@export var max_health : float = 3
@export var regen_time : int = 150
@export var invincability_time : int = 30

@export_subgroup("Attack Properties")
@export var basic_damage : float = 0.5
@export var reload_time : int = 20
@export var basic_range : float = 1.0

@export_subgroup("Extra Properties")
@export var speed : float = 1

@onready var dmg_collider : CollisionShape2D = $PlayerDmgArea/PlayerDmgBox
@onready var hurt_area : Area2D = $HurtArea
@onready var animated_sprite_2d = $AnimatedSprite2D

var velocity : Vector2
var prev_direction : int = 1
var health : float = 0
var current_regen : int = 0
var current_reload : int = 0
var attacking : bool = false

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * speed

func die():
	# ANIMATION: play death animation and end game
	Global.end_game()
	queue_free()

func injured(area : Area2D):
	if invincability_time > regen_time - current_regen:
		return
	if area.name == "DmgArea":
		# ANIMATION: play damage animation (make player red)
		health -= 1.0
		current_regen = regen_time
		if health <= 0.0: die()

func attack_start():
	dmg_collider.scale = Vector2(current_range, 1)
	if current_reload <= 0:
		# ANIMATION: play attack animation (priority over walking? maybe white slash instead)
		durability -= 1
		dmg_collider.disabled = false
		current_reload = reload_time
	elif current_reload < reload_time >> 1:
		if durability <= 0:
			damage = basic_damage
			current_range = basic_range
		dmg_collider.disabled = true
	current_reload -= 1

func attack_stop():
	if durability == 0:
		damage = basic_damage
		current_range = basic_range
	dmg_collider.disabled = true
	current_reload = 0

func _input(event : InputEvent):
	if is_instance_of(event, InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT:
			attacking = event.is_pressed()

func _ready():
	health = max_health
	hurt_area.area_entered.connect(injured)
	dmg_collider.disabled = true

func _physics_process(_delta):
	if health <= 0.0: return
	if health < max_health:
		current_regen -= 1
		if current_regen <= 0:
			# ANIMATION: play healing animation (make him green)
			health += 1
			current_regen = regen_time
			
	if attacking: attack_start()
	else: attack_stop()
	
	var direction = sign(global_position.direction_to(get_viewport().get_mouse_position()).x)
	if direction != 0 and prev_direction != direction:
		prev_direction = - prev_direction
		apply_scale(Vector2(-1, 1))
		
	get_input()
	if velocity.length_squared() == 0:
		animated_sprite_2d.play("idle")
		pass
	else:
		animated_sprite_2d.play("run")
		pass
	global_position.x = clampf(global_position.x + velocity.x, border_left, border_right)
	global_position.y = clampf(global_position.y + velocity.y, border_top, border_bottom)
