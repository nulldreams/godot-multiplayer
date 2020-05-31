extends Node
 
const ICON_PATH = "res://assets/items/icons/"

const ITEMS = {
	"sword": {
		"icon": ICON_PATH + "sword.png",
		"slot": "MAIN_HAND"
	},
	"axe": {
		"icon": ICON_PATH + "axe.png",
		"slot": "OFF_HAND"
	},
	"food": {
		"icon": ICON_PATH + "food.png",
		"slot": "NONE"
	},
	"error":{
		"icon": ICON_PATH + "error.png",
		"slot": "NONE"
	}
}

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]
