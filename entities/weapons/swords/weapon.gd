extends Node2D

export var weapon_owner = ''
export var weapon_texture = "sword"

func _ready():
	$Sprite.texture = load(weapons_map.weapon_list[weapon_texture].simple)

func _physics_process(delta):
	$Sprite.texture = load(weapons_map.weapon_list[weapon_texture].simple)

#sync func change_weapon(weapon):
#	if not is_network_master():
#		return
#	weapon_texture = weapons[weapon].simple


func _on_weapon_body_entered(body):
	if not is_network_master():
		return
	if body.name != name:
		var knockbak_direction = (global_position - body.global_position).normalized()
		var knockback_range = knockbak_direction * 10000
		body.rpc("hit", knockback_range * Vector2(-1, -1))
