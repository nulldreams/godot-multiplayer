extends Node2D

var player_name = ''

func _ready():
	pass


func _on_LineEdit_text_changed(new_text):
	player_name = new_text


func _on_Create_pressed():
	network.create_server('SERVER')
	_load_game()

func _load_game():
	get_tree().change_scene("res://scenes/game.tscn")


func _on_Join_pressed():
	network.connect_to_server('CLIENT')
	_load_game()
