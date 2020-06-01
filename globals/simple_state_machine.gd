extends Node

enum {
	STATE_IDLE,
	STATE_RUNNING,
	STATE_ATTACKING,
	STATE_HURT
}
var state = STATE_IDLE

func _ready():
	pass

remote func check_state(motion, player, entitie_data):
	if motion == Vector2.ZERO:
		state = STATE_IDLE
	if motion != Vector2.ZERO:
		state = STATE_RUNNING
	if entitie_data.actions.attacking:
		state = STATE_ATTACKING
	if entitie_data.actions.hurt:
		state = STATE_HURT
	set_weapon(player, entitie_data)
	state_machine(player, entitie_data)
	
func state_machine(player, entitie_data):
	match state:
		STATE_IDLE:
			idle(player)
		STATE_RUNNING:
			running(player)
		STATE_ATTACKING:
			attacking(player, entitie_data)
		STATE_HURT:
			hit(player)

func attacking(player, entitie_data):
	change_animation(player, "attacking")

func idle(player):
	change_animation(player, "idle")

func running(player):
	change_animation(player, "running")

func hit(player):
	var player_sprite = get_tree().get_root().get_node(player.get_path()).get_node("Sprite")

func set_weapon(player, entitie_data):
	var weapon = get_tree().get_root().get_node(player.get_path()).get_node("weapon")
	weapon.weapon_texture = entitie_data.equipment.weapon

func change_animation(player, animation):
	var player_sprite = get_tree().get_root().get_node(player.get_path()).get_node("Sprite")
	player_sprite.play(animation)
	var weapon_sprite = get_tree().get_root().get_node(player.get_path()).get_node("weapon/animation_player")
	weapon_sprite.play(animation)
