extends RigidBody3D # TO DO: what parent class should we use for ammo? StaticBody3D would be best, but need to confirm it moves when placed on platforms
class_name PickableItem 

# TO DO: how large should pickup radius be (currently 0.5m)

# TO DO: would it be cheaper to have a single Cylinder collision Area on Player that detects all pickable items entering it?


@export var item_type: Constants.PickableType



func _ready() -> void:
	pass


func picked_up() -> void: # items can also be picked up by other players, so keep this method separate
	queue_free()
	print("picked up ammo type ", item_type)


func _on_pickup_body_entered(body: Node) -> void: # collision_mask=[Player]
	body.found_item(self) # Player.found_item(item) will call item.picked_up() if the Player adds the item to its inventory (this call goes to Player, not directly to Inventory, so that Player can update its HUD and play picked-up animation when the Inventory accepts the item)

