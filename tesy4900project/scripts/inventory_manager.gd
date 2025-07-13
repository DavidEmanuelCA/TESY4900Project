extends Node

var inventory : Dictionary

func add_to_inventory(type : String, value : String):
	inventory[type] = value

func has_inventory_item(value : String) -> bool:
	var item = inventory.find_key(value)
	
	if item:
		return true
	
	return false
