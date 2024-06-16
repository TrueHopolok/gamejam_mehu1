extends Button

@export_subgroup("Weapon Properties")
@export var damage : float = 1.0
@export var durability : int = 10
@export var attack_size : float = 1.0

@export_subgroup("Cost")
@export var cost : Array[int] = \
[0, 0, 0]

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var cost_labels = get_children()

func _pressed():
	for i in range(min(len(Global.materials_amount), len(cost))):
		if Global.materials_amount[i] < cost[i]:
			return
	for i in range(min(len(Global.materials_amount), len(cost))):
		Global.materials_amount[i] -= cost[i]
	player.weapon_damage = damage
	player.durability = durability + Global.extra_durability
	player.max_durability = durability + Global.extra_durability
	player.attack_size = attack_size
	# change weapon texture/image

func _physics_process(_delta):
	for label in cost_labels:
		label.visible = is_hovered()
