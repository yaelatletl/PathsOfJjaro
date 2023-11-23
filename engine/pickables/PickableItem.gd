extends RigidBody3D
class_name PickableItem 

# TO DO: how large should pickup radius be (currently 0.5m)

@export var item_type: int = 0 # could use enum, but let's leave it open-ended and use ints or interned strings (ints are cheaper but interned strings are more descriptive)



func _ready() -> void:
	pass


func picked_up() -> void:
	queue_free()
	print("picked up ammo type ", item_type)


func _on_pickup_body_entered(body: Node) -> void: # collision_mask=[Player]
	body.found_item(self) # Player.found_item(item) will call item.picked_up() if the Player adds the item to its inventory


