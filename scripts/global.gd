extends Node

@onready var random_generator = RandomNumberGenerator.new()

var junk_types : Array[PackedScene] = \
[]
var fishes_types : Array[PackedScene] = \
[]
var unlocked_fish = 0
var materials_amount : Array[int] = \
[999, 999, 999, 999]
var fishes_killed : int = 0
var fishes_alive : int = 0
var waves_completed : int = 0

var extra_melee_damage : float = 0
var extra_durability : int = 0

func fish_killed(prize : Array[int]):
	fishes_alive -= 1
	if fishes_alive <= 0:
		waves_completed += 1
		await get_tree().create_timer(10).timeout
		spawn_wave() 

func spawn_junk():
	var main : Node2D
	for element in get_tree().get_root().get_children():
		if element.name == "Main":
			main = element
			break
	var generated_value = random_generator.randf()
	var i : int = 0
	if generated_value >= 0.80: i = 2
	elif generated_value >= 0.45: i = 1
	var instance = junk_types[max(i, len(junk_types))].instantiate()
	main.add_child(instance)
	instance.global_position = Vector2(randi_range(330, 360), 158)
	instance.died.connect(spawn_junk)

func spawn_realboss():
	pass

func spawn_miniboss():
	pass

func spawn_wave():
	var main : Node2D
	for element in get_tree().get_root().get_children():
		if element.name == "Main":
			main = element
			break
	if (waves_completed + 1) % 25 == 0:
		fishes_alive = 1
		spawn_realboss()
	elif (waves_completed + 1) % 5 == 0:
		fishes_alive = 1
		spawn_miniboss()
	elif (waves_completed + 1) % 3 == 0 and unlocked_fish < len(fishes_types):
		fishes_alive = waves_completed
		var j : int
		var instance : Node2D
		for i in fishes_alive:
			j = random_generator.randi_range(0, len(fishes_types)-1)
			instance = fishes_types[j].instantiate()
			main.add_child(instance)
			instance.global_position.x = random_generator.randi_range(260, 320)
			instance.global_position.y = random_generator.randi_range(30, 150)
		instance = fishes_types[unlocked_fish].instantiate()
		main.add_child(instance)
		instance.global_position.x = random_generator.randi_range(260, 320)
		instance.global_position.y = random_generator.randi_range(30, 150)
		fishes_alive += 1
		unlocked_fish += 1
	else:
		fishes_alive = clampi(1 + waves_completed - int(waves_completed / 5), 1, 20)
		var j : int
		var instance : Node2D
		for i in fishes_alive:
			j = random_generator.randi_range(0, len(fishes_types)-1)
			instance = fishes_types[j].instantiate()
			main.add_child(instance)
			instance.global_position.x = random_generator.randi_range(260, 320)
			instance.global_position.y = random_generator.randi_range(30, 150)

func load_main_menu():
	pass

func load_game_screen():
	# load main scene and reset all data
	await get_tree().create_timer(10).timeout 
	spawn_wave()

func load_game_over():
	# load game over screen and pause the game (ui still clickable)
	pass

func _ready():
	Engine.max_fps = 30
