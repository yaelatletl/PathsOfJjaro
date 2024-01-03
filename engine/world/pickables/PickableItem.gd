extends Prop # We use the prop class, it's a rigid body and we can use custom integrators to make it move only when we want it to
class_name PickableItem 


# PickableItem.gd

# @hhas: would it be cheaper to have a single Cylinder collision Area on Player that detects all pickable items entering it?
# @810-Dude: Yes

# @hhas: how large should pickup radius be (currently 0.5m)?
# @810-Dude: Doesn't matter, we should go with the cylinder collision shape in the player and have it detect all pickables in a radius


func _ready() -> void:
	custom_physics = true # this is a rigid body, but we don't want it to move unless we tell it to
	can_sleep = true
	body_entered.connect(_on_pickup_body_entered)
	body_exited.connect(_on_pickup_body_exited)
	custom_integrator = true 
	pass 
	# TODO: need to load the displayed mesh from assets/pickables, selected by PickableType; 
	# this sort of thing is probably easiest with a global manager that auto-loads all scenes 
	# from a given directory into the corresponding asset lookup table (one table for pickables, 
	# one for visual effects, one for props, etc; alternatively one big dictionary where keys are 
	# combination of AssetType and subtype, e.g. `AssetType.Pickable|PickableType`, with AssetType 
	# enums using the high byte and subtype enums using the 3 low bytes)
	
# TODO: if PickableItem.can_sleep is true, there is an obvious problem where ammo placed on the moving platform is 
# pushed up by rising platform but does not fall down again as platform lowers 
# (it's also impossible for player to pick up once it's pushed); this is a physics issue, obvs, 
# Q. should all pickables be simple static bodies, and any placed on platforms 
# become the platform's responsibility to move - the platform's own 
# collision detection can find it and add it to an array of items that the
# platform will move in sync to its own movements
# most pickable items *never* move, so having to do any physics at all on them is a waste of resources; 
# alternatively, if we implement Pickable as RigidBody then it probably makes sense to freeze the stationary 
# pickables so they aren't a significant load (we can set the freeze flag in the map editor when the Pickable node is added to the map)

# @810-Dude: "For pickables, we can sleep them but have them report collisions, this way we can detect if they're suddenly floating and awake them"
#
# TODO: problem with Pickable detection: if player has full ammo when stepping into item's detection range, 
# then depletes that ammo by firing weapon till it reloads, the item they're standing on isn't picked up 
# until player leaves and re-enters the item's detection area. 
# (The item should pick up as soon as inventory has space.) 

# @hhas: "May be best for Player to detect pickables: 
# it can track them entering and exiting in an array/dictionary, and any time inventory decrements an 
# item check that list for a potential replacement."
# @810-Dude: Agreed!

@export var pickable_type: Enums.PickableType

func picked_up() -> void: # items can also be picked up by other players, so keep this method separate
	queue_free()
	print("picked up ammo type ", pickable_type)

# TODO: this was the function before:
#func _on_pickup_body_entered(body: Node) -> void: # collision_mask=[Player]
	#body.found_item(self)
	# Player.found_item(item) will call item.picked_up() 
	#if the Player adds the item to its inventory 
	# (this call goes to Player, not directly to InventoryManager, so that Player 
	# can update its HUD and play picked-up animation when the InventoryManager accepts the item)
# But we don't actually want to detect the player, we want the player to detect the pickable! 
# So we need to move this function to the player script and have it detect the pickable. 
# Also, area detection is better than body detection, as it's more efficient and flexible.
var collisions = [] # list of bodies currently colliding with this item
func _on_pickup_body_entered(body: Node3D) -> void:
	# Here we actually need to manage the collision with scenery and structures!
	# Need to keep a cache of all bodies currently colliding with this item, and remove them when they leave
	# also wake up the item if it's sleeping and the colliding object leaves
	collisions.append(body)

func _on_pickup_body_exited(body: Node3D) -> void:
	collisions.erase(body)
	sleeping = false # wake up the item if it's sleeping and the colliding object leaves