extends RigidBody2D

export var weapon_name = ""

func _ready():
	$Sprite.texture = load(weapons_map.weapon_list[weapon_name])
