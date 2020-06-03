extends Node2D

export var weapon_owner = ""
export var weapon_texture = "sword"

func _ready():
	$Sprite.texture = load(weapons_map.weapon_list[weapon_texture])

func _physics_process(delta):
	$Sprite.texture = load(weapons_map.weapon_list[weapon_texture])


func _on_weapon_body_entered(body):
	if not is_network_master():
		return
	if can_deal_damage(body):
		var knockbak_direction = (global_position - body.global_position).normalized()
		var knockback_range = knockbak_direction * 10000
		body.rpc("hit", knockback_range * Vector2(-1, -1))

func can_deal_damage(body):
	return body.name != weapon_owner.name and $animation_player.current_animation == "attacking"
