extends CanvasLayer

@onready var material_amount_labels : Array[Label] = \
[$Wood/Amount, $Rope/Amount, $Metal/Amount, $Fish/Amount]

func _process(_delta):
	for i in range(len(material_amount_labels)):
		material_amount_labels[i].text = "x"+str(Global.materials_amount[i])
