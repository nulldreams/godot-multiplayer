extends RigidBody2D

export var weapon_name = ""
var show_popup = false
var remove = false

func _ready():
	$Sprite.texture = load(weapons_map.weapon_list[weapon_name])

func _physics_process(delta):
	set_popup_position()
	if !show_popup:
		$Popup.hide()
	else:
		$Popup.show()
		

func show_popup():
	show_popup = true

func hide_popup():
	show_popup = false

func set_popup_position():
	var sprite_position = $".".position
	sprite_position.x -= 25
	sprite_position.y -= 40
	$Popup.set_position(sprite_position)

func _on_PickupRange_body_entered(body):
	pass

sync func pickup():
	$Dust.emitting = true
	$Sprite.hide()
	$DustTimer.start()


func _on_DustTimer_timeout():
	self.queue_free()
