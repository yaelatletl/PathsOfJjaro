extends Node3D
@onready var start = $Start
@onready var end = $End

const AREA_RADIUS = 2

var interactable
var zipline_direction = Vector3.ZERO

var current_bodies = []
var linked_bodies = []
var area : Area3D
@export var y_offset: float = 0.7
#little struct here:
#{
#	body: body,
#	zip_direction: Vector3,

#}

func _ready():
	area = Area3D.new()
	var collision = CollisionShape3D.new()
	var distance = start.global_transform.origin.distance_to(end.global_transform.origin)
	var angle = start.global_transform.origin.angle_to(end.global_transform.origin)
	var debug_shape = MeshInstance3D.new()
	zipline_direction = start.global_transform.origin.direction_to(end.global_transform.origin)
	debug_shape.mesh = BoxMesh.new()
	area.name = "PickArea"
	collision.shape = BoxShape3D.new()
	collision.shape.extents = Vector3(AREA_RADIUS, AREA_RADIUS, distance)/2
	debug_shape.mesh.size = collision.shape.extents*2
	area.connect("body_exited",Callable(self,"_on_body_exited"))
	interactable = InteractableInterface.new()
	interactable.cooldown = 0.5
	interactable.toggable = true
	area.add_child(collision)
	area.add_child(debug_shape)
	interactable.add_child(area)
	add_child(interactable)
	area.global_transform.origin = start.global_transform.origin
	area.global_translate(Vector3(0, -y_offset, 0))
	interactable.message = "Press E to use Zipline"
	area.position += zipline_direction*(distance / 2)
	area.look_at(end.global_transform.origin, Vector3(0, 1, 0))
	interactable.connect("interacted_successfully",Callable(self,"_on_interacted_successfully"))

func _on_interacted_successfully(body):
	if body in linked_bodies:
		_on_body_exited(body)
	else:
		hook_on(body)

func hook_on(body):
	if body.has_method("_get_component"):
		var struct = {}
		struct["body"] = body
		struct["zip_direction"] = body.head_basis.z.dot(zipline_direction)
		if body._get_component("movement_basic"):
			struct["movement"] = body._get_component("movement_basic")
		else:
			struct["movement"] = null
		linked_bodies.append(body)
		current_bodies.append(struct)
		body.global_transform.origin = get_point_to_snap(body.global_transform.origin)

func _on_body_exited(body):
	if not body in linked_bodies:
		return
	for phys_body in current_bodies:
		if phys_body["body"] == body:
			print(phys_body)
			_on_body_deattached(phys_body)
			

func _on_body_deattached(struct, delta=0.0):
	for i in current_bodies.size():
		if current_bodies[i]["body"] == struct["body"]:
			var body = current_bodies[i]["body"]
			if current_bodies[i]["body"] in linked_bodies:
				linked_bodies.erase(current_bodies[i]["body"])
				current_bodies[i]["movement"].add_impulse(-body.head_basis.z.normalized() * body.linear_velocity.length())
			current_bodies.remove_at(i)
			break

func get_point_to_snap(actor_origin : Vector3):
	var distance_to_start = actor_origin.distance_to(start.global_transform.origin)
	var distance_to_end = actor_origin.distance_to(end.global_transform.origin)
	var distance_to_start_end = start.global_transform.origin.distance_to(end.global_transform.origin)
	var nearest = min(distance_to_start, distance_to_end)
	var intersection = Vector3.ZERO
	if nearest == distance_to_start:
		intersection = start.global_transform.origin
		intersection += zipline_direction.normalized()*(nearest)
	else:
		intersection = end.global_transform.origin
		intersection -= zipline_direction.normalized()*(nearest)
	return intersection

func _physics_process(delta):
	for struct in current_bodies:
		if not area.overlaps_body(struct["body"]):
				_on_body_deattached(struct, delta)
				return
				
		if struct["zip_direction"] > 0:
			if struct["body"].global_transform.origin.distance_to(start.global_transform.origin) < 1:
				_on_body_deattached(struct, delta)
			else:
				#struct["body"].linear_velocity = zipline_direction * -10 
				struct["body"].linear_velocity = struct["body"].global_transform.origin.direction_to(start.global_transform.origin) * 10
		else:
			if struct["body"].global_transform.origin.distance_to(end.global_transform.origin) < 1:
				_on_body_deattached(struct, delta)
			else:
				#struct["body"].linear_velocity = zipline_direction * 10 
				struct["body"].linear_velocity = struct["body"].global_transform.origin.direction_to(end.global_transform.origin) * 10
