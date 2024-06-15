extends CanvasLayer

@onready var material_amount_labels : Array[Label] = \
[$Wood/Amount, $Rope/Amount, $Metal/Amount, $Fish/Amount]
@onready var weapon_buttons : Array[Button] = \
[$DaggerButton, $SpearButton, $AxeButton, $SwordButton]
@onready var cost_labels : Array[Label] = \
[]

var weapon_stats : Array[WeaponStats] = \
[
	WeaponStats.new(1.0, 10, 1.0, 1, 1, 0),
	WeaponStats.new(1.0, 30, 1.5, 1, 1, 1),
	WeaponStats.new(2.0, 30, 1.0, 2, 2, 2),
	WeaponStats.new(1.5, 60, 1.0, 1, 1, 4),
]

var player_node : Player = null

func _ready():
	for element in get_parent().get_children():
		if is_instance_of(element, Player):
			player_node = element
			break

func _physics_process(_delta):
	for i in range(len(material_amount_labels)):
		material_amount_labels[i].text = "x"+str(Global.materials_amount[i])
