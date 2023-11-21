extends Node3D

# weapon_manager.gd


# TO DO: what is lifetime for this? it should not be on Player node unless Player is instantiated outside of Level (i.e. Player is stored in Global)



# TO DO: Weapons should not need all these properties: it needs camera vector to aim and player to automatically reload/switch out if depleted, so the Player node should be passed to each Weapon upon instantiating it

# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)


# TO DO: whereas M2's primary and secondary trigger inputs operate independently for dual weapons (fists, pistols, shotguns), we want to make dual-wielding largely automatic: if [loaded] dual weapons are available then always show both on screen. Pressing primary/secondary trigger fires the corresponding left/right weapon first; if user holds the trigger for repeating fire then the opposite weapon fires next, and so on. This allows user to empty one pistol (by repeatedly tapping to fire the same gun) if they wish to manage exactly when left/right pisto, reloads occur, or to hold down either trigger and have both weapons fire and reload themselves.


# Get actor's node path
@onready var actor = get_parent()
# Get head's node path
@export var head_path : NodePath = ""
# Get camera's node path
@export var camera_path : NodePath = "" 

@onready var head = get_node(head_path)
@onready var neck = get_node(str(head_path) + "/neck")
@onready var camera = get_node(camera_path)


var weapon_definitions := [
	# TO DO: get AR working correctly, then add remaining weapon definitions here
	{
		# the visual representation of this weapon; this implements a standard API for triggering its animations
		"view_model": preload("res://assets/weapons/assault_rifle/weapon_in_hand.tscn"),
		
		"name": "ma75b",
		"itemType": 5, # determines weapon switching order (TO DO: weapons order is problematic in M2 as empty alien gun switches to rocket launcher but should switch to AR or lower so that user doesn't accidentally spnkr themselves)
		"weaponClass": 4,
		
		"flags": 1,

		"readyTicks": 15,

		"idleHeight": 76458,
		"idleWidth": 32768,
		"bobAmplitude": 1872,
		"horizontalAmplitude": 0,

		"collection": 1,
	  
		"trigger0": {
			"ammunitionType": 6,
			"roundsPerMagazine": 52,
			"ticksPerRound": -1,
			
			"recoveryTicks": 0,
			"chargingTicks": 0,
			
			"recoilMagnitude": 5,
			
			# replace shapes and sounds with AnimationPlayer with standard names
			
			"soundActivationRange": 7,
			
			"projectileType": 3,
			"thetaError": 10,
			
			# point relative to player center from which projectile emits
			"dx": 0,
			"dz": -20,
			
			"burstCount": 0,
			
			# moved these properties into Trigger, although they arguably belong on weapon_in_hand.tscn
			"firingLightIntensity": 49152,
			"firingIntensityDecayTicks": 6,
			"kickHeight": 8192,
			"reloadHeight": 49152,

			"awaitReloadTicks": -1,
		},

		"trigger1": {
			"ammunitionType": 7,
			"roundsPerMagazine": 7,
			"ticksPerRound": 5,
			"recoveryTicks": 17,
			"chargingTicks": 0,
			"recoilMagnitude": 40,
			
			"soundActivationRange": 10,
			"projectileType": 1,
			"thetaError": 0,
			"dx": 0,
			"dz": -100,
			"burstCount": 0,

			"firingLightIntensity": 49152,
			"firingIntensityDecayTicks": 6,
			"kickHeight": 8192,
			"reloadHeight": 49152,

			"awaitReloadTicks": -1,
		},
	},
]

var player_weapons := []

var enabled = true

# Current weapon
@onready var user_scale = scale

# Current weapon
var current : int = 0 #sync


func _ready() -> void:

	set_as_top_level(true)
	actor._register_component("weapons", self)

	# Class reference : 
	# owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed
	#for tag in arsenal:
		#...

	
	# Class reference : 
	# owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed

	#add actors first, then add weapons to tree, otherwise their _ready() code will break
	#for w in arsenal:
	#	add_child(arsenal[w])
	#	arsenal.values()[current]._hide()
	_change()

func _physics_process(_delta) -> void:
	if not enabled:
		return
	# Call weapon function
	_weapon(_delta)
	if actor.input["next_weapon"]:
		var next = arsenal.values()[current]
		_handle_guns(next)

func _process(_delta) -> void:
	_rotation(_delta)
	_position(_delta)

func _shoot(_delta) -> void:
	# Call weapon function
	arsenal.values()[current].shoot(_delta)

func _reload() -> void:
	arsenal.values()[current].reload()

func _weapon(_delta) -> void:
	arsenal.values()[current]._sprint(actor.input["sprint"] or actor.input["jump"], _delta)
	
	if not actor.input["sprint"] or not (actor.direction.length()==0.0):
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
	var quat_a = global_transform.basis.get_rotation_quaternion()
	var quat_b = camera.global_transform.basis.get_rotation_quaternion()
	var angle_distance = quat_a.angle_to(quat_b)
	if not actor.input["zoom"] and angle_distance < PI/2:
		global_transform.basis = Basis(quat_a.slerp(quat_b, _delta*x_lerp*angle_distance))
	else:
		rotation = camera.global_transform.basis.get_euler()

func _change_weapon(_index) -> void:
	current = _index
	_change()

func _handle_guns(next):
		if not next.check_relatives():
			if next.update_spatial_parent_relatives(self):
				_handle_guns(next)
			else:
				pass
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
