extends CanvasLayer

@onready var material_amount_labels : Array[Label] = \
[$Wood/Amount, $Rope/Amount, $Metal/Amount, $Fish/Amount]

func _physics_process(_delta):
	for i in range(len(material_amount_labels)):
		material_amount_labels[i].text = "x"+str(Global.materials_amount[i])
