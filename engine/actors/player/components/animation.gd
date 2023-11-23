extends AnimationPlayer


# TO DO: camera animations should be called from Player, which should know its own state and handle its own transitions from one state to another; for now, it is simpler to put all code in Player.gd and, if/when that file grows large and unwieldy, move portions of functionality into their own files

# only camera.position.y should change (height and frequency is specified by physics so it might be simplest to lerp it in _physics_process; although we can use animation player if it's easier)


# Get character's node path

# this pattern is a bad code smell: this is why "components" are really not helpful: every class ends up tightly, implicitly coupled to every other class; that the dependency graph is dynamically constructed by Godot runtime doesn't make it any less of an incomprehensible snarl; while it is possible to devise a plugin API that isn't a nightmare, there is no point trying to design it before understanding what it needs to support by building v1.0 of the app without it: a good architecture can always be extracted into components later; a bad (premature) component system makes a good, reliable, understandable architecture very hard to develop
@export var character_path: NodePath
@export var camera_path: NodePath
@export var movement_path: NodePath

@onready var character = get_node(character_path)
@onready var camera = get_node(camera_path)
@onready var movement = get_node(movement_path)


func _process(_delta):
	# A dynamic animation function for the neck
	#_neck_animation(_delta)

	# Calls a function with animations
	#_animation()
	
	pass



func _animation() -> void: # this animates head bob when walking/sprinting; TO DO: get rid of this and play bob animations in Player
	
	# If the player presses the jump button
	if character.input["jump"]:
		# Checks if the jump animation is active
		if current_animation != "jump":
			# Starts the jump animation
			play("jump", 0.3)

	# If the character is moving
	if character.direction:
		# If the current animation is not a walk
		if current_animation != "jump":
			if character.input["sprint"]:
				if current_animation != "sprint":
					play("sprint", 0.3, 1.5)
			else:
				if current_animation != "walk":
					play("walk", 0.3)
	else:
		# If the current animation is not idle
		if current_animation != "idle" and current_animation != "jump":
			# Starts animation with smoothing
			play("idle", 0.3, 0.1)

func _neck_animation(_delta) -> void:
	# Neck rotation speed
	if not movement:
		movement = get_node(movement_path)
	var rotation_speed : float = movement.n_speed * _delta 

	# Get the camera node

	# Creates the angle based checked the character's movement # player tilts when sidestepping; don't think we want this for MCR though
	#character.angle = 2 * (character.input["right"] + -character.input["left"])
	

	# Apply an interpolation to neck rotation based checked angle
	camera.rotation.z = lerp(camera.rotation.z, -deg_to_rad(character.angle), rotation_speed)
