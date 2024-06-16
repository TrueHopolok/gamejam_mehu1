extends TextureRect


@export var regular_texture : Texture

@onready var player : Player = get_tree().get_first_node_in_group("Player") 

func _physics_process(_delta):
	if player.durability <= 0: texture = regular_texture
