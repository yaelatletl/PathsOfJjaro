extends Weapon

export(PackedScene) var Projectile = preload("res://assets/weapons/spnkr_missile.tscn")
export(PackedScene) var squib = preload("res://Basics/Guns/squib.tscn")

export var spread = 20

func _process(delta):
	if in_magazine == 2:
		$missile_slot.set_visible(true)
		$missile_slot2.set_visible(true)
	if in_magazine == 1:
		$missile_slot.set_visible(false)
		$missile_slot2.set_visible(true)
	if in_magazine == 0:
		$missile_slot.set_visible(false)
		$missile_slot2.set_visible(false)

func _ready():
	identity = "SPNKR-X17 SSM Launcher (Lazyboy)"
	in_magazine = 2
	in_secondary_magazine = 0
	primary_magazine_size = 2
	secondary_magazine_size = 0
	primary_ammo_id = 4
	secondary_ammo_id = 4

	
func primary_fire():

	#check if the weapon has cooled
	if can_shoot:
		
		
		# check if there is ammo in the magazine
		if ammo_check_primary():
			
			# load a missile as an instance
				var missile = Projectile.instance()
				missile.setup(wielder)
				
				# add the missile to the right aperture
				if in_magazine == 1:
					missile.set_global_transform($missile_slot.get_global_transform())
					get_node("/root").add_child(missile)
					
					
				elif in_magazine == 0:
					missile.set_global_transform($missile_slot2.get_global_transform())
					get_node("/root").add_child(missile)
					#$missile_slot2.add_child(missile)
			# weapon set not chambered, start timer for cooldown.
				can_shoot=false
				$chamber_timer.start()

func secondary_fire():
	primary_fire()
	
func _on_chamber_timer_timeout():
	can_shoot = true

# "M .75 ammunition is neither vacuum enabled nor teflon coated, and due to a manufacturing defect is highly inaccurate at long range."
# used for random spread. 
func randomshoot():
	
	randomize()
	var randx = rand_range(-spread, spread)
	randomize()
	var randy = rand_range(-spread, spread)


	var newx = 0 + randx
	var newy = 0 + randy


