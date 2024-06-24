extends Node

@onready var game_scene : PackedScene = preload("res://scenes/main.tscn")
@onready var main_menu_scene : PackedScene = preload("res://scenes/main_menu.tscn")
@onready var pirahna_prefab : PackedScene = preload("res://scenes/fish/fish_pirahna.tscn")
@onready var special_fish_prefabs : Array[PackedScene] = \
[
	preload("res://scenes/fish/sword_fish.tscn"),
	preload("res://scenes/fish/fuga_fish.tscn"),
	preload("res://scenes/fish/angler_fish.tscn"), 
	preload("res://scenes/fish/hammer_head_fish.tscn"),
	preload("res://scenes/fish/stingray_fish.tscn"),
]
@onready var junk_types : Array[PackedScene] = \
[
	preload("res://scenes/junk/junk_wood.tscn"),
	preload("res://scenes/junk/junk_rope.tscn"),
	preload("res://scenes/junk/junk_metal.tscn"),
]  
var junk_amounts : Array[int] = [3, 1, 2]

var unlocked_fishes : int = 0

var fishes_killed : int = 0
var fishes_alive : int = 0
var waves_completed : int = 0

var materials_amount : Array[int] = \
[0, 0, 0, 0]

var extra_melee_damage : float = 0
var extra_durability : int = 0
var extra_projectile_damage : float = 0
var extra_raft_health : float = 0

func fish_killed():
	fishes_killed += 1
	fishes_alive -= 1
	if fishes_alive == 0:
		waves_completed += 1
		await get_tree().create_timer(max(15.0 - waves_completed * 0.1, 3.0)).timeout
		while get_tree().paused: await get_tree().create_timer(3.0).timeout
		spawn_wave() 

func spawn_junk():
	while true:
		var junk_to_spawn = []
		for i in len(junk_types):
			for j in junk_amounts[i]:
				junk_to_spawn.append(i)
		randomize()
		junk_to_spawn.shuffle()
		while len(junk_to_spawn) > 0:
			var main = get_tree().get_first_node_in_group("SCENE_main")
			if main == null: return
			var instance : Junk = junk_types[junk_to_spawn.pop_back()].instantiate()
			main.add_child(instance)
			instance.global_position = Vector2(randi_range(330, 360), randi_range(30, 150))
			await get_tree().create_timer(randf_range(3.0, 6.0)).timeout
			while get_tree().paused: await get_tree().create_timer(1.0).timeout

func spawn_wave():
	var main = get_tree().get_first_node_in_group("SCENE_main")
	if main == null: return
	var audio : AudioStreamPlayer = get_tree().get_first_node_in_group("SFX_nextwave")
	if audio != null: audio.play()
	randomize()
	
	var instance : Fish
	fishes_alive = clampi(1 + waves_completed, 1, 20)
	var must_spawn : int = fishes_alive
	
	if unlocked_fishes < len(special_fish_prefabs) and (waves_completed + 1) % 5 == 0:
		must_spawn -= 1
		instance = special_fish_prefabs[unlocked_fishes].instantiate()
		unlocked_fishes += 1
		main.add_child(instance)
		instance.global_position.x = randi_range(330, 360)
		instance.global_position.y = randi_range(60, 120)
		instance.died.connect(fish_killed)
		while must_spawn > 0:
			must_spawn -= 1
			instance = pirahna_prefab.instantiate()
			main.add_child(instance)
			instance.global_position.x = randi_range(330, 360)
			instance.global_position.y = randi_range(30, 150)
			instance.died.connect(fish_killed)
		return
	
	while must_spawn > 0:
		must_spawn -= 1
		if unlocked_fishes != 0 and must_spawn % 4 == 0:
			instance = special_fish_prefabs[randi_range(0, unlocked_fishes - 1)].instantiate()
		else: 
			instance = pirahna_prefab.instantiate()
		main.add_child(instance)
		if waves_completed >= 25:
			var value : int = randi_range(0, 1)
			if value == 0: instance.global_position.x = randi_range(330, 360)
			else: instance.global_position.x = randi_range(-30, 0)
		else: instance.global_position.x = randi_range(330, 360)
		instance.global_position.y = randi_range(30, 150)
		instance.died.connect(fish_killed)

func load_game_screen():
	get_tree().get_root().get_child(1).queue_free()
	get_tree().get_root().add_child(game_scene.instantiate())
	randomize()
	special_fish_prefabs.shuffle() 
	unlocked_fishes = 0
	materials_amount = [0, 0, 0, 0]
	fishes_killed = 0
	fishes_alive = 0
	waves_completed = 0
	extra_melee_damage = 0
	extra_durability = 0
	extra_projectile_damage = 0
	extra_raft_health = 0
	spawn_junk()
	await get_tree().create_timer(5.0).timeout 
	while get_tree().paused: await get_tree().create_timer(1.0).timeout
	spawn_wave()

func load_game_over():
	get_tree().get_root().get_child(1).queue_free()
	get_tree().get_root().add_child(main_menu_scene.instantiate())

func _ready():
	Engine.max_fps = 30
