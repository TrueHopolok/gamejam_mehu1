extends Node

@onready var random_generator = RandomNumberGenerator.new()

var junk_types : Array[PackedScene] = \
[
	load("res://scenes/junk/junk_wood.tscn"),
	load("res://scenes/junk/junk_rope.tscn"),
	load("res://scenes/junk/junk_metal.tscn"),
]
var fish_prefab : PackedScene = load("res://scenes/fish/fish_pirahna.tscn")
var materials_amount : Array[int] = \
[0, 0, 0, 0]
var fishes_killed : int = 0
var fishes_alive : int = 0
var waves_completed : int = 0

var extra_melee_damage : float = 0
var extra_durability : int = 0
var extra_projectile_damage : float = 0
var extra_raft_health : float = 0

func fish_killed():
	fishes_alive -= 1
	if fishes_alive <= 0:
		waves_completed += 1
		await get_tree().create_timer(5).timeout
		spawn_wave() 

func spawn_junk():
	var main = get_tree().get_first_node_in_group("Main")
	var generated_value = random_generator.randf()
	var i : int = 0
	if generated_value >= 0.80: i = 2
	elif generated_value >= 0.45: i = 1
	var instance = junk_types[min(i, len(junk_types)-1)].instantiate()
	main.add_child(instance)
	instance.global_position = Vector2(randi_range(330, 360), 158)
	instance.died.connect(spawn_junk)

func spawn_wave():
	var main = get_tree().get_first_node_in_group("Main")
	fishes_alive = clampi(1 + waves_completed - int(waves_completed / 5), 1, 20)
	var j : int
	var instance : Node2D
	for i in fishes_alive:
		instance = fish_prefab.instantiate()
		main.add_child(instance)
		instance.global_position.x = random_generator.randi_range(260, 320)
		instance.global_position.y = random_generator.randi_range(30, 150)
		instance.died.connect(fish_killed)


func load_game_screen():
	get_tree().get_root().get_child(1).queue_free()
	get_tree().get_root().add_child(load("res://scenes/main.tscn").instantiate())
	materials_amount = [0, 0, 0, 0]
	fishes_killed = 0
	fishes_alive = 0
	waves_completed = 0
	extra_melee_damage = 0
	extra_durability = 0
	extra_projectile_damage = 0
	extra_raft_health = 0
	spawn_junk()
	await get_tree().create_timer(3).timeout 
	spawn_wave()

func load_game_over():
	get_tree().get_root().get_child(1).queue_free()
	get_tree().get_root().add_child(load("res://scenes/main_menu.tscn").instantiate())
	pass

func _ready():
	Engine.max_fps = 30
	
