extends RigidBody3D # TO DO: what parent class should we use for ammo? StaticBody3D would be best, but need to confirm it moves when placed on platforms
class_name PickableItem 

# TO DO: how large should pickup radius be (currently 0.5m)

# TO DO: would it be cheaper to have a single Cylinder collision Area on Player that detects all pickable items entering it?


# TO DO: if PickableItem.can_sleep is true, there is an obvious problem where ammo placed on the moving platform is pushed up by rising platform but does not fall down again as platform lowers (it's also impossible for player to pick up once it's pushed); this is a physics issue, obvs, 

# Q. should all pickables be simple static bodies, and any placed on platforms become the platform's responsibility to move - the platform's own collision detection can find it and add it to an array of items that the platform will move in sync to its own movements
#
# most pickable items *never* move, so having to do any physics at all on them is a waste of resources; alternatively, if we implement Pickable as RigidBody then it probably makes sense to freeze the stationary pickables so they aren't a significant load (we can set the freeze flag in the map editor when the Pickable node is added to the map)




@export var pickable: Enums.PickableType



func _ready() -> void:
	pass


func picked_up() -> void: # items can also be picked up by other players, so keep this method separate
	queue_free()
	print("picked up ammo type ", pickable)


func _on_pickup_body_entered(body: Node) -> void: # collision_mask=[Player]
	body.found_item(self) # Player.found_item(item) will call item.picked_up() if the Player adds the item to its inventory (this call goes to Player, not directly to Inventory, so that Player can update its HUD and play picked-up animation when the Inventory accepts the item)

