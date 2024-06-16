extends ProgressBar

@onready var player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta):
	if player == null: return
	visible = player.durability > 0
	if visible:	value = player.durability * 100 / player.max_durability
