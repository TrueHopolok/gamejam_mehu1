class_name WeaponStats

var damage : float = 1.0
var durability : int = 1
var attack_range : float = 1.0
var wood_cost : int = 1
var rope_cost : int = 1
var metal_cost : int = 1

func _init(dmg : float, dur : int, rng : float, wcost : int, rcost : int, mcost : int):
	damage = dmg
	durability = dur
	attack_range = rng
	wood_cost = wcost
	rope_cost = rcost
	metal_cost = mcost
