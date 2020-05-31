extends Node

enum {
	STATE_IDLE,
	STATE_RUNNING,
	STATE_ATTACKING,
	STATE_HURT
}
var state = STATE_IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
	var player_sprite = get_tree().get_root().get_node(player.get_path()).get_node("Sprite")
	var weapon_sprite = get_tree().get_root().get_node(player.get_path()).get_node("weapon/animation_player")
	weapon_sprite.play("attack")

func idle(player):
	var player_sprite = get_tree().get_root().get_node(player.get_path()).get_node("Sprite")
	var weapon_sprite = get_tree().get_root().get_node(player.get_path()).get_node("weapon/animation_player")
	player_sprite.play("idle")
	weapon_sprite.play("idle")

func running(player):
	var player_sprite = get_tree().get_root().get_node(player.get_path()).get_node("Sprite")
	player_sprite.play("running")

func hit(player):
	var player_sprite = get_tree().get_root().get_node(player.get_path()).get_node("Sprite")
#	player_sprite.play("hurt")

func set_weapon(player, entitie_data):
	var weapon = get_tree().get_root().get_node(player.get_path()).get_node("weapon")
	weapon.weapon_texture = entitie_data.equipment.weapon
	print(player.name, " ", weapon.weapon_texture)
