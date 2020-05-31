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

remote func check_state(motion, sprite, entitie_data):
	if motion == Vector2.ZERO:
		state = STATE_IDLE
	if motion != Vector2.ZERO:
		state = STATE_RUNNING
	if entitie_data.attacking:
		state = STATE_ATTACKING
	if entitie_data.hurt:
		state = STATE_HURT

	state_machine(sprite, entitie_data)
	
func state_machine(sprite, entitie_data):
	match state:
		STATE_IDLE:
			idle(sprite)
		STATE_RUNNING:
			running(sprite)
		STATE_ATTACKING:
			attacking(sprite, entitie_data)
		STATE_HURT:
			hit(sprite)

func attacking(sprite, entitie_data):
	sprite.play("attacking")

func idle(sprite):
	sprite.play("idle")

func running(sprite):
	sprite.play("running")

func hit(sprite):
	sprite.play("hurt")
