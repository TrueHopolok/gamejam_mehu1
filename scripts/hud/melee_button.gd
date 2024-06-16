extends Button

@export_subgroup("Power-up Properties")
@export var damage : float = 0.2
@export var durability : int = 0

@export_subgroup("Cost")
@export var cost_fish : int = 1
@export var cost_increase : int = 1

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var cost_label = $CostLabel

func _pressed():
	if Global.materials_amount[3] < cost_fish: return
	Global.materials_amount[3] -= cost_fish
	Global.extra_melee_damage += damage
	Global.extra_durability += durability
	cost_fish += cost_increase
	cost_label.text = str(cost_fish)

func _physics_process(_delta):
	cost_label.visible = is_hovered()
