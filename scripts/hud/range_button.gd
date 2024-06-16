extends TextureButton

@export_subgroup("Power-up Properties")
@export var projectile_damage : float = 0.2
@export var raft_health : float = 1

@export_subgroup("Cost")
@export var cost_fish : int = 1
@export var cost_increase : int = 1

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var cost_label = $CostLabel

func _pressed():
	if Global.materials_amount[3] < cost_fish: return
	Global.materials_amount[3] -= cost_fish
	Global.extra_projectile_damage += projectile_damage
	Global.extra_raft_health += raft_health
	cost_fish += cost_increase
	cost_label.text = str(cost_fish)

func _physics_process(_delta):
	cost_label.visible = is_hovered()
