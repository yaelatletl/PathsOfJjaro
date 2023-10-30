extends Component

enum INPUT_TYPE {
	MOVEMENT,
	AIM,
	COMBAT, 
	ANY
}

#Class that converts information to input values. 
var navigator : NavigationAgent3D = null
var movement : Node = null
var planner : Node = null
var team : int = 0

@onready var navigator_planned_position : Vector3 # = actor.feet.global_transform.origin

@export var jump_treshold : float = 1.2
@export var crouch_treshold : float = -5.0
@export var maximum_collision_distance : float = 1.0
@export var distance_treshold : float = 1.0
@export var reaction_speed : float = 20.0

@onready var head_clone : RayCast3D = actor.get_node("head_clone")

@onready var view_target : Vector3 = actor.global_transform.origin

@onready var actor_state = ActorState.new() 
#This is the actual brain of the actor, it contains all the information about the actor's state and what it should do.
#It requires an agent child node to work properly.

#var feet_to_head_difference : float = 0.0

var shoot_target : Node3D = null
var navigating : bool = false

signal target_reached()
signal view_target_changed(target) 
signal shoot_at_target(target)


func _ready() -> void:
	#We need to know the distance between the feet and the head, so we can mantain natural looking aim.
	#feet_to_head_difference = actor.head.global_transform.origin.y + actor.feet.cast_to.y #cast_to is already negative
	assert(head_clone != null, "Head clone is null, please add a head clone (raycast) to the actor scene for orientation calulations.")
	actor._register_component("input", self)
	head_clone.cast_to = Vector3(0, 0, -maximum_collision_distance)
	navigator = actor._get_component("navigation")
	movement = actor._get_component("movement_basic")
	get_null_input(INPUT_TYPE.ANY)
	var agent = GoapAgent.new(self, [])
	add_child(agent)

func get_null_input(type : int) -> void:
	if type == INPUT_TYPE.AIM or type == INPUT_TYPE.ANY:
		actor.input["look_y"] = 0
		actor.input["look_x"] = 0
	if type == INPUT_TYPE.MOVEMENT or type == INPUT_TYPE.ANY:
		actor.input["left"]   = 0
		actor.input["right"]  = 0
		actor.input["forward"] = 0
		actor.input["back"]   = 0
		actor.input["jump"] = 0
		actor.input["extra_jump"] = 0
		actor.input["crouch"] = 0
		actor.input["sprint"] = 0
	if type == INPUT_TYPE.COMBAT or type == INPUT_TYPE.ANY:
		actor.input["special"] = 0
		actor.input["use"] = 0
		actor.input["next_weapon"] = 0
		actor.input["shoot"] = 0
		actor.input["reload"] = 0
		actor.input["zoom"] = 0


func look_ahead() -> void:
	var look_at = Vector3.ZERO
	if navigator.path.size()>2:
		look_at = (navigator.path[1]+ navigator.path[2]) / 2 #looks more natural
	elif navigator.path.size()>1:
		#if the path is too short we can't do much
		look_at = navigator.path[1]
	else:
		return
	look_at.y = actor.head.global_transform.origin.y
	set_view_target(look_at)

func move_towards_goal() -> void:
	#We have to determine what inputs allow us to get to the desired position, even if were not looking at it. 
	if navigator == null:
		print("No navigator, returning null input.")
		return
	if not navigating:
		print("Navigation finished, returning null input.")
		navigator_planned_position = actor.feet.global_transform.origin
		return
	var next_position = navigator.next_path_position
	if  get_distance() < distance_treshold:
		actor.direction = Vector3.ZERO
		return
	if navigator.path.size() > 1:
		actor.direction = navigator.path[0].direction_to(navigator.path[1]) 
	if Engine.get_physics_frames()%4==0:
		#We only want to update the path every 4 frames, otherwise we update it too often.
		navigator.update_path(navigator_planned_position)

func get_distance() -> float:
	return actor.feet.global_transform.origin.distance_to(navigator_planned_position)

func set_view_target(target : Vector3) -> void:
	view_target = target
	emit_signal("view_target_changed", target)

func set_target(position : Vector3) -> void:
	if position.distance_to(navigator_planned_position) > distance_treshold:
		navigator_planned_position = position
		navigator.go_to(position)
		navigating = true

func aknowledge_navigation_finished() -> void:
	#We have to aknowledge that the navigation is finished, so we can get new input.
	navigator_planned_position = actor.feet.global_transform.origin
	navigating = false
	emit_signal("target_reached")

func point_to_target(target : Vector3) -> void:
	if target == null or target == Vector3.ZERO or view_target == Vector3.ZERO:
		return
	#We have to rotate the head to look at the target
	head_clone.look_at(target, Vector3.UP)
	var view_vector = actor.head.global_transform.basis.z
	var target_vector = head_clone.global_transform.basis.z
	var y_vector = Vector2(view_vector.x, view_vector.z)
	var x_vector = Vector2(y_vector.length(), view_vector.y)
	var y_target = Vector2(target_vector.x, target_vector.z)
	var x_target = Vector2(y_target.length(), target_vector.y)
	#var our_direction = actor.global_transform.origin.direction_to(target)
	#var angle = head_basis.xform(our_direction).normalized().y
	actor.input["look_x"] = (y_vector.angle_to(y_target)*reaction_speed) 
	actor.input["look_y"] = (x_vector.angle_to(x_target)*reaction_speed)

func point_and_shoot(target : Node3D) -> void:
	set_view_target(target.head.global_transform.origin)
	if head_clone.is_colliding():
		if head_clone.get_collider() == target:
			shoot(target)
			print("Shoot")
		else:
			get_null_input(INPUT_TYPE.COMBAT)

############################### FUNCTIONS FOR REFACTORING #########################################

func _physics_process(delta : float) -> void:
	if get_distance() > distance_treshold:
		move_towards_goal()
		look_ahead()
	else:
		if navigating:
			aknowledge_navigation_finished()
		#get_null_input(INPUT_TYPE.MOVEMENT)
		actor.direction = Vector3.ZERO
		if shoot_target != null:
			point_and_shoot(shoot_target)
	point_to_target(view_target)


func shoot(target : Node3D) -> void:
	#Uhhh, how do we assign targets to homing missiles?
	actor.input["shoot"] = 1
	#we emit a signal that tells the weapon to shoot at the target
	if target != null:
		emit_signal("shoot_at_target", target)

############ FUNCTIONS FOR ACTORSTATE COMMUNICATION ######################

func _on_camera_player_entered(body : Node3D) -> void:
	#Player on the camera, we can now get the input.
	#Exclude parent 
	if body == actor or navigator == null:
		return
	else:
		#Inform the ActorState that we have a target
		actor_state.set_target(body)
		#shoot_target = body
	#navigator_planned_position = body.feet.global_transform.origin
	#set_view_target(body.head.global_transform.origin)
	#set_target(body.feet.global_transform.origin)
