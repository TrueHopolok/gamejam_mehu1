extends TextureButton

@export var bus_name : String
@onready var bus_index : int = AudioServer.get_bus_index(bus_name)

func _ready():
	button_pressed = AudioServer.is_bus_mute(bus_index)

func _toggled(toggled_on):
	AudioServer.set_bus_mute(bus_index, toggled_on)
