extends Spatial

# Get actor's node path
onready var actor = get_parent()

# Get head's node path
export(NodePath) var head

# Get camera's node path
export(NodePath) var neck

# Get camera's node path
export(NodePath) var camera

# All weapons
var arsenal : Dictionary

# Current weapon
remotesync var current : int = 0


func _ready() -> void:
	set_as_toplevel(true)
	actor._register_component("weapons", self)

	# Get camera node from path
	camera = get_node(camera)

	# Get neck node from path
	neck = get_node(neck)

	# Get head node from path
	head = get_node(head)

	# Class reference : 
	# owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed
	arsenal["zeus"] = FormatParser.weapon_from_json("res://assets/weapons/tags/zeus.json", self)
	arsenal["plasma"] = FormatParser.weapon_from_json("res://assets/weapons/tags/alien_gun.json", self)
	arsenal["ma75b"] = FormatParser.weapon_from_json("res://assets/weapons/tags/ma75b.json", self)
	# Create mk 23 using weapon classs
	arsenal["mk_23"] = FormatParser.weapon_from_json("res://assets/weapons/tags/mk_23.json", self)

	# Create glock 17 using weapon class
	arsenal["glock_17"] = FormatParser.weapon_from_json("res://assets/weapons/tags/glock_17.json", self)
	# Create glock 17 using weapon class
	arsenal["shotgun"] = FormatParser.weapon_from_json("res://assets/weapons/tags/shotgun.json", self)
	# Create kriss using weapon class
	arsenal["kriss"] = FormatParser.weapon_from_json("res://assets/weapons/tags/kriss.json", self)

	#add actors first, then add weapons to tree, otherwise their _ready() code will break
	for w in arsenal:
		add_child(arsenal[w])
		arsenal.values()[current]._hide()
	_change()

func _physics_process(_delta) -> void:
	# Call weapon function
	_weapon(_delta)
	if actor.input["next_weapon"]:
		var next = arsenal.values()[current]
		_handle_guns(next)

func _process(_delta) -> void:
	_rotation(_delta)
	_position(_delta)

remote func add_weapon(name : String, path : String, view_model : PackedScene) -> void:
	var model = view_model.instance()
	arsenal[name] = FormatParser.weapon_from_json(path, self)
	model.name = arsenal[name].gun_name
	print("Added weapon: " + name)
	add_child(arsenal[name])
	add_child(model)
	arsenal.values()[current]._hide()

remote func _shoot(_delta) -> void:
	# Call weapon function
	arsenal.values()[current].shoot(_delta)
	Gamestate.call_on_all_clients(self, "_shoot", _delta)

remote func _reload() -> void:
	arsenal.values()[current].reload()
	Gamestate.call_on_all_clients(self, "_reload", null)

func _weapon(_delta) -> void:
	arsenal.values()[current]._sprint(actor.input["sprint"] or actor.input["jump"], _delta)
	
	if not actor.input["sprint"] or not actor.direction:
		if actor.input["shoot"]:
			_shoot(_delta)
		
		arsenal.values()[current]._zoom(actor.input["zoom"], _delta)
	
	if actor.input["reload"]:
		_reload()
	
	arsenal.values()[current]._update(_delta)

func _change() -> void:
	# change weapons
	for w in range(arsenal.size()):
		if arsenal.values()[w] != arsenal.values()[current]:
			arsenal.values()[w]._hide()
		else:
			arsenal.values()[w]._draw()

func _position(_delta) -> void:
	global_transform.origin = head.global_transform.origin
	
func _rotation(_delta) -> void:
	var y_lerp = 40
	var x_lerp = 80
	var quat_a = global_transform.basis.get_rotation_quat()
	var quat_b = camera.global_transform.basis.get_rotation_quat()
	var angle_distance = quat_a.angle_to(quat_b)
	if not actor.input["zoom"] and angle_distance < PI/2:
		global_transform.basis = Basis(quat_a.slerp(quat_b, _delta*x_lerp*angle_distance))
	else:
		rotation = camera.global_transform.basis.get_euler()

remotesync func _change_weapon(_index) -> void:
	current = _index
	Gamestate.set_in_all_clients(self, "current", _index)
	_change()

func _handle_guns(next):
		if not next.check_relatives():
			next.update_spatial_parent_relatives(self)
			_handle_guns(next)
		else:
			var anim = arsenal.values()[current].anim
			if not anim.is_playing():
				if current + 1 < arsenal.size():
					_change_weapon(current + 1)
				else:
					_change_weapon(0)

func add_ammo(name, ammo) -> void:
	arsenal[name].add_ammo(ammo)
	pass
