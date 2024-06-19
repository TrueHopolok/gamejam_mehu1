extends TextureButton

@export var placeable_id : int = 0
@export var cost : Array[int] = \
[0, 0, 0]

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var cost_labels = get_children()
@onready var placeable_texture : TextureRect = get_parent().find_child("BuildingIcon")

func _pressed():
	player.current_placeable = placeable_id
	placeable_texture.texture = texture_normal

func _process(_delta):
	for label in cost_labels:
		label.visible = is_hovered()
