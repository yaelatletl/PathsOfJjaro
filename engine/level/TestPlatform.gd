extends Node3D
class_name Platform

# TO DO: we don't need platforms for Arrival Demo; however it'd be useful to get the behavior and visual structure worked out now; note: this current implementation is experimental and will require changes to make it fully reusable and configurable (see exported map JSONs for platform config dictionary)



# TO DO: should doors/platforms be RigidBody3D or AnimatableBody3D? rigid is physics-dependent (which might be handy if we want them to respond "organically" to mass impacts, e.g. jumping onto a moving platform transfers some impulse to it, making it slightly bounce underfoot) whereas [animated] static body is code-controlled and needs its own Area collision detection to prevent pushing Player/NPCs through floor/wall/ceiling
#
# for now, use StaticBody3D (or its AnimatableBody3D subclass) and move it directly; this replicates M2 behavior (caveat it needs collision Areas to detect Player/NPC) and applies force to Player/NPCs/items/etc when it makes contact with them (this is not true physics, just an approximation, but it's "good enough")


# TO DO: we can use Platform.move_and_collide() in _physics_process to move the platform up and down; however, it must leave collision_mask empty otherwise it instantly stops moving when it contacts Level/Player/NPC/etc; not sure about lifting platforms: will those report a collision when something's on top?


# note: this scene is currently set up in test map as a rising/falling platform which is ACTION-activated


# TO DO: should doors and platforms have their own collision layer? or can they use same layer as Level wall? if they respond to ACTION, they need an Area collision with collision_layer=ControlPanel so the Player's DetectControlPanel raycast can detect it

# TO DO: closing doors and moving platforms need to respond to Player/NPC collisions, e.g. some doors/platforms will reverse while others will crush; what we do NOT want is Player/NPC being pushed through floor by physics (which is what currently happens when standing under the moving platform in test map); Wheeels solved this by adding an additional collision area that moved along with the door itself (upon colliding it reopened the door), plus another collision area that aborted the close operation if Player or NPCs were standing too close to door and reset the close timer to try again later - however, Wheeels didn't have to support lifting platforms or airborne bodies; it might be necessary to build crush detection into doors and platforms as thin collision Areas positioned against both crushing surfaces - any object that collides with both Areas at same time receives crush damage


# note: use Area enter/exit to trigger pressure-activated platforms

# note: while some moving objects may follow non-linear paths, those are best implemented as their own custom classes, so KISS here and support common-case linear movement only (usually up/down, though may be some other direction depending on marker positions)


# TO DO: while we could use AnimationPlayer, it's probably best to stick to numeric values as these can be imported directly from the exported level JSONs

@export var active  := true : get = get_active, set = set_active # public; start/stop platform; TO DO: not sure about naming as "active" could be confused with "enabled"
@export var moving  := active : get = get_moving
@export var move_up := true # the platform's direction when moving; the initial direction can be set in map editor
@export_range(0.1, 1000.0) var speed     := 1.0 # TO DO: may have different up/down speeds
@export_range(0.0, 1000.0) var wait_time := 1.0


@onready var platform := $Platform
# markers indicate extent of movement (nice idea! however, these need to be independently positioned within the map scene, not in Platform.tscn itself; it may be simpler to @export top_position and bottom_position as Vector3 coordinates, or use distances from ends of a 3D bounding box into which the Platform is placed by mapmaker), allowing door/platform extents to be set in-map (in Classic these limits had to be defined as absolute heights in the platform's settings, which was a pain); TO DO: for doors, if markers are omitted then calculate the extents from the door's collision shape?; markers should also work in any direction (subtracting one from other gives a vector to which speed can be applied); the other problem with current implementation is that it's using centerpoints whereas we really want the moving face
@onready var top_marker    := $Top
@onready var bottom_marker := $Bottom


@onready var switch := $ActionHandler/ControlPanel


var __destination: Vector3 # top or bottom marker position, depending on current direction of travel
var __velocity: Vector3


func _ready() -> void:
	set_active(active)


func __update_velocity() -> void:
	if moving:
		__destination = (top_marker if move_up else bottom_marker).position
		var v = (top_marker.global_position - bottom_marker.global_position).normalized() * speed
		__velocity = (v if move_up else -v) # TO DO: may want to apply impulse (if RigidBody3D)
	else:
		__velocity = Vector3.ZERO


func set_active(is_active: bool) -> void:
	active = is_active
	if switch: # Godot sets the @export properties before binding @onready switch before calling _ready, so the first time set_active is called (by `@export active` assignment) the `switch` var isn't yet bound (this code is all experimental anyway until we decide how mapmakers connect switches and platforms together)
		__set_moving(is_active)
		switch.mesh.material.albedo_color = Color.GREEN if is_active else Color.RED

func get_active() -> bool:
	return active


func __set_moving(is_moving: bool) -> void:
	moving = is_moving
	__update_velocity()

func get_moving() -> bool:
	return moving


func _physics_process(delta: float):
	if moving:
		var remaining_distance = platform.position.y - __destination.y
		if (remaining_distance > 0.01) if move_up else (remaining_distance < -0.01): # TO DO: may want to reduce velocity when distance <10cm for more realistic platform acceleration/deceleration or soft-opening/closing door
			move_up = not move_up
			if wait_time > 0:
				__set_moving(false)
				__update_velocity()
				await get_tree().create_timer(wait_time).timeout
				__set_moving(true)
			__update_velocity()
	# TO DO: what about collision detection? if we set collision_mask=[Player,NPC] the platform stops as soon as player steps onto it, which isn't what we want; however, we do want to detect if player gets trapped underneath platform or is pressed into ceiling (in which case a safe platform stops/reverses and an unsafe platform crushes)
	var col = platform.move_and_collide(__velocity * delta) # for now, collision_mask=[] allows platform to move through floor and won't stop when player steps on top/underneath it; a body caught underneath a descending platform can be detected by a collision Area positioned under Platform's bottom plane (caveat this will also detect an airborne Player or flying NPC which should apply impulse but not crush); TO DO: detecting bodies above and below platform needs more thought
	if col:
		print(platform, " collided with ", col)
		self.active = false




# Player pressed ACTION while looking at the control Area
func do_action(activating_body: Node3D, activating_area: Area3D) -> void: # activating_body is the Player that requested the action; activating_area is the node that received the request and passed it on to this platform # TO DO: return bool indicating success/failure? or should any feedback be provided by calling methods on the objects passed in?
	self.active = not self.active



