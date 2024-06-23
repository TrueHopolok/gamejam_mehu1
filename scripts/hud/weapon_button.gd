extends TextureButton

@export_subgroup("Weapon Properties")
@export var damage : float = 1.0
@export var durability : int = 10
@export var attack_size : float = 1.0

@export_subgroup("Cost")
@export var cost : Array[int] = \
[0, 0, 0]

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var weapon_icon : TextureRect = get_parent().find_child("WeaponIcon")

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
	weapon_icon.texture = texture_normal

func _process(_delta):
	for label in get_children():
		label.visible = is_hovered()
