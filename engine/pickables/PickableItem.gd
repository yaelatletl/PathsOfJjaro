extends Node
class_name PickableItem 

# TO DO: how large should pickup radius be (currently 1.5m)

var item_type: int # could use enum, but let's leave it open-ended and use ints or interned strings (ints are cheaper but interned strings are more descriptive)


func _ready() -> void:
	pass


func picked_up() -> void:
	get_parent().remove_node(self)



func _on_pickup_body_entered(body: Node) -> void: # TO DO: set Collision Layer and Mask correctly so that only Player is passed here
	# TO DO: this is wrong
	body.found_item(self) # Player.found_item(item) will call item.picked_up() if the Player adds the item to its inventory


