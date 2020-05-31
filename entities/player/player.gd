extends KinematicBody2D

var attack_direction = Vector2.ZERO

var movement = {
	"motion": Vector2.ZERO,
	"acceleration": 500,
	"max_speed": 170
}
var entitie_data = {
	"attacking": false,
	"ray_cast": null,
	"hurt": false
}

enum {
	STATE_RUNNING
}

slave var slave_position = Vector2.ZERO
slave var slave_movement = Vector2.ZERO
slave var slave_axis = Vector2.ZERO
slave var slave_entitie_data = entitie_data

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.x <= -0.707:
		$player_sword.scale.x = -1
		$Sprite.flip_h = true
	elif norm_direction.x >= 0.707:
		$Sprite.flip_h = false
		$player_sword.scale.x = 1

func get_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	var normalized = axis.normalized()
	return normalized

func apply_friction(amount):
	if movement.motion.length() > amount:
		movement.motion -= movement.motion.normalized() * amount
	else:
		movement.motion = Vector2.ZERO

func apply_movement(acceleration):
	movement.motion += acceleration
	movement.motion = movement.motion.clamped(movement.max_speed)

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("attack"):
		entitie_data.attacking = true
		if is_network_master():
			$player_sword/CollisionPolygon2D.disabled = false

func _physics_process(delta):
	var axis = Vector2.ZERO
	if is_network_master():
		$Camera2D.current = true
		axis = get_axis()
		get_animation_direction(axis)
		if axis == Vector2.ZERO:
			apply_friction(movement.acceleration * delta)
		else:
			apply_movement(axis * movement.acceleration * delta)
		simple_state_machine.check_state(movement.motion, $Sprite, entitie_data)
		rset('slave_entitie_data', entitie_data)
		rset('slave_axis', axis)
		rset_unreliable('slave_position', position)
		rset('slave_movement', movement.motion)
		movement.motion = move_and_slide(movement.motion)
	else:
		simple_state_machine.check_state(slave_movement, $Sprite, slave_entitie_data)
		get_animation_direction(slave_axis)
		move_and_slide(slave_movement)
		position = slave_position
		
	if get_tree().is_network_server():
		network.update_position(int(name), position)

func init(nickname, start_position, is_slave):
	$Name.text = nickname
	global_position = start_position

func _on_HitBox_area_shape_entered(area_id, area, area_shape, self_shape):
	pass

func _on_AttackDuration_timeout():
	if entitie_data.attacking:
		entitie_data.attacking = false
		if is_network_master():
			$player_sword/CollisionPolygon2D.disabled = true

func _on_player_sword_body_entered(body):
	if not is_network_master():
		return
	if body.name != name:
		var knockbak_direction = (global_position - body.global_position).normalized()
		var knockback_range = knockbak_direction * 5000
		body.rpc("hit", knockback_range * Vector2(-1, -1))

sync func hit(knockback):
	apply_movement(knockback)
	entitie_data.hurt = true
	$HurtDuration.start()
	return true

func _on_HurtDuration_timeout():
	entitie_data.hurt = false
