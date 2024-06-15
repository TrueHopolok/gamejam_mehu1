extends CanvasLayer

@onready var wood_amount_label : Label = $Wood/Amount
@onready var rope_amount_label : Label = $Rope/Amount
@onready var fish_amount_label : Label = $Fish/Amount 
@onready var metal_amount_label : Label = $Metal/Amount

func _physics_process(_delta):
	wood_amount_label.text = "x"+str(Global.materials_wood)
	rope_amount_label.text = "x"+str(Global.materials_rope)
	fish_amount_label.text = "x"+str(Global.materials_fish)
	metal_amount_label.text = "x"+str(Global.materials_metal)
