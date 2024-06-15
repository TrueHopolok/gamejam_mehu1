class_name Player extends Node2D

@export_subgroup("Weapon Properties")
@export var weapon_damage : float = 0.5
@export var durability : int = 0
@export var attack_size : float = 1

@export_subgroup("Game Area Borders")
@export var border_top : int = 12
@export var border_bottom : int = 18+16*9+6
@export var border_left : int = 32
@export var border_right : int = 32+16*13

@export_subgroup("Health Properties")
@export var max_health : float = 3
@export var regen_reload : int = 150
@export var invincability_time : int = 30

@export_subgroup("Attack Properties")
@export var basic_damage : float = 0.5
@export var attack_reload : int = 20
@export var basic_attack_size : float = 1.0

@export_subgroup("Extra Properties")
@export var speed : float = 1

@onready var dmg_collider : CollisionShape2D = $PlayerDmgArea/PlayerDmgBox
@onready var hurt_area : Area2D = $HurtArea
@onready var animated_sprite_2d = $AnimatedSprite2D

var damage : float
var velocity : Vector2
var prev_direction : int = 1
var health : float = 0
var current_regen : int = 0
var current_reload : int = 0
var attacking : bool = false

func die():
	# ANIMATION: play death animation and end game
	Global.game_over()
	queue_free()

func injured(area : Area2D):
	if invincability_time > regen_reload - current_regen:
		return
	if area.name == "DmgArea":
		# ANIMATION: play damage animation (make player red)
		health -= 1.0
		current_regen = regen_reload
		if health <= 0.0: die()

func attack():
	if current_reload > 0: return
	# ANIMATION: show white slash as attack (add as child of PlayerDmgBox) 
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
	damage += Global.strength

func _ready():
	health = max_health
	hurt_area.area_entered.connect(injured)
	dmg_collider.disabled = true

func _physics_process(_delta):
	if health <= 0.0: return
	
	if current_reload > 0:
		current_reload -= 1
		dmg_collider.disabled = true
	
	if health < max_health:
		current_regen -= 1
		if current_regen <= 0:
			# ANIMATION: play healing animation (make him green)
			health += 1
			current_regen = regen_reload
	
	var direction = sign(global_position.direction_to(get_viewport().get_mouse_position()).x)
	if direction != 0 and prev_direction != direction:
		prev_direction = - prev_direction
		apply_scale(Vector2(-1, 1))
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		attack()
	
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	if velocity.length_squared() == 0:
		animated_sprite_2d.play("idle")
		pass
	else:
		animated_sprite_2d.play("run")
		pass
	global_position.x = clampf(global_position.x + velocity.x, border_left, border_right)
	global_position.y = clampf(global_position.y + velocity.y, border_top, border_bottom)
