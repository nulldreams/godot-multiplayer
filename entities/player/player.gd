extends KinematicBody2D

export var current_weapon = "sword"
var can_interact = false
var droped_item = {
	"name": null,
	"node": null
}

var movement = {
	"motion": Vector2.ZERO,
	"acceleration": 500,
	"max_speed": 170
}
var entitie_data = {
	"equipment": {
		"weapon": current_weapon
	},
	"actions": {
		"attacking": false,
		"hurt": false,		
	},
	"movement": {
		"motion": Vector2.ZERO,
		"acceleration": 500,
		"max_speed": 170
	},
	"position": Vector2.ZERO,
	"axis": Vector2.ZERO
}

enum {
	STATE_RUNNING
}

slave var slave_position = Vector2.ZERO
slave var slave_entitie_data = entitie_data

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.x <= -0.707:
		if !$Sprite.flip_h:
			turn_weapon()
		$Sprite.flip_h = true
	elif norm_direction.x >= 0.707:
		if $Sprite.flip_h:
			turn_weapon()
		$Sprite.flip_h = false

func turn_weapon():
	$weapon.position.x *= -1
	$weapon.scale.x *= -1

func get_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	var normalized = axis.normalized()
	return normalized

func apply_friction(amount):
	if entitie_data.movement.motion.length() > amount:
		entitie_data.movement.motion -= entitie_data.movement.motion.normalized() * amount
	else:
		entitie_data.movement.motion = Vector2.ZERO

func apply_movement(acceleration):
	entitie_data.movement.motion += acceleration
	entitie_data.movement.motion = entitie_data.movement.motion.clamped(entitie_data.movement.max_speed)

func _ready():
	$weapon.weapon_owner = self

func _physics_process(delta):
	var axis = Vector2.ZERO
	if is_network_master():
		$Camera2D.current = true
		axis = get_axis()
		get_animation_direction(axis)
		if axis == Vector2.ZERO:
			apply_friction(entitie_data.movement.acceleration * delta)
		else:
			apply_movement(axis * entitie_data.movement.acceleration * delta)
		entitie_data.equipment.weapon = current_weapon
		entitie_data.axis = axis
		entitie_data.position = position
		simple_state_machine.check_state(entitie_data.movement.motion, $".", entitie_data)
		rset_unreliable('slave_entitie_data', entitie_data)
		entitie_data.movement.motion = move_and_slide(entitie_data.movement.motion)
	else:
		simple_state_machine.check_state(slave_entitie_data.movement.motion, $".", slave_entitie_data)
		get_animation_direction(slave_entitie_data.axis)
		move_and_slide(slave_entitie_data.movement.motion)
		position = slave_entitie_data.position
		
	if get_tree().is_network_server():
		network.update_position(int(name), position)

func init(nickname, start_position, is_slave):
	$Name.text = nickname
	global_position = start_position

func _on_HitBox_area_shape_entered(area_id, area, area_shape, self_shape):
	pass

func _input(event):
	if event.is_action_pressed("attack"):
		entitie_data.actions.attacking = true
		$AttackDuration.start()
	if event.is_action_pressed("interact") and can_interact and droped_item:
		change_weapon(droped_item)

func _on_AttackDuration_timeout():
	if entitie_data.actions.attacking:
		entitie_data.actions.attacking = false

func _on_player_sword_body_entered(body):
	if not is_network_master():
		return
	if body.name != name:
		var knockbak_direction = (global_position - body.global_position).normalized()
		var knockback_range = knockbak_direction * 20000
		body.rpc("hit", knockback_range * Vector2(-1, -1))

sync func hit(knockback):
	apply_movement(knockback)
	entitie_data.actions.hurt = true
	$HurtDuration.start()
	return true

func change_weapon(weapon):
	current_weapon = weapon.name
	weapon.node.rpc("pickup")

func _on_HurtDuration_timeout():
	entitie_data.actions.hurt = false

func _on_PickupRange_body_entered(body):
	if not body.is_in_group("droped_items"):
		return
	body.show_popup()
	can_interact = true
	droped_item.name = body.weapon_name
	droped_item.node = body


func _on_PickupRange_body_exited(body):
	if not body.is_in_group("droped_items"):
		return
	can_interact = false
	body.hide_popup()
