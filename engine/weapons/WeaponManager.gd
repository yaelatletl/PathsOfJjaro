extends Node3D
class_name WeaponManager

# WeaponManager.gd -- manages all Weapon instances on behalf of Player, and provides an API by which Player can get the current Weapon instance, switch to previous/next weapon, and enable/disable a weapon when it is picked up/dropped


# TO DO: might want to make this global InventoryManager and manage ammo and other items too (since weapons are part of, and need access to, inventory)


# TO DO: what is lifetime for WeaponManager? what is lifetime for Player? WeaponManager might be better as a singleton along with other level-independent player state (inventory, health)



# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)


# TO DO: whereas M2's primary and secondary trigger inputs operate independently for dual weapons (fists, pistols, shotguns), we want to make dual-wielding largely automatic: if [loaded] dual weapons are available then always show both on screen. Pressing primary/secondary trigger fires the corresponding left/right weapon first; if user holds the trigger for repeating fire then the opposite weapon fires next, and so on. This allows user to empty one pistol (by repeatedly tapping to fire the same gun) if they wish to manage exactly when left/right pisto, reloads occur, or to hold down either trigger and have both weapons fire and reload themselves.


# TO DO: decide how best to organize player Inventory; not sure that attaching ammo count to Weapon[Trigger] is a good idea; better to have Ammunition instances for all player ammo types which are managed by Inventory; these instances can be shared with WeaponTrigger instances so that a Trigger decrements Ammunition.count when it reloads and Inventory increments it when an ammo Pickable is picked up



var weapon_definitions := [
	# TO DO: get AR working correctly, then add remaining weapon definitions here
	{
		
		"long_name": "MA75B Assault Rifle", # show this in Inventory overlay
		"short_name": "MA75B", # show this in HUD
		
		"max_count": 1,
		"current_count": 1, # 1 for testing; normally 0 for everything except fist (2) and pistol (1)
		
		
		"item_type": &"assault_rifle",
		
		#"powerup_type": null,
		"weapon_class": "multipurpose",
		
		# TO DO:
		"flags": {
			"is_automatic": true, # true for AR, SPNKR, flamethrower, alien gun, flechette gun; not sure what it does though as other weapons also fire repeatedly when trigger key is held down
			"disappears_after_use": false, # true for alien gun
			#"plays_instant_shell_casing_sound": false, # always false
			"overloads": false, # true for fusion pistol (Q. what is overload timeout in M2? check AO code)
			"has_random_ammo_on_pickup": false, # true for alien gun
			#"powerup_is_temporary": false, # always false
			"reloads_in_one_hand": false, # true for shotgun
			"fires_out_of_phase": false, # true for pistol but not sure what it does, if anything
			"fires_under_media": false, # true for fists, fusion pistol, flechette gun (note that firing fusion underwater causes radius damage, though not sure if this is the Projectile or Weapon which does this; Q. does firing fusion into water also do radius damage, or is it only when weapon itself is submerged?)
			"triggers_share_ammo": false, # true for fusion pistol and alien gun, false for others
			"secondary_has_angular_flipping": false # true for alien gun
		},
		
		# TO DO: these belong in weapon assets's shoot and reload animations
		#"idle_height": 1.1666565,
		#"bob_amplitude": 0.028564453,
		#"idle_width": 0.5,
		#"horizontal_amplitude": 0.0,
		#"kick_height": 0.0625, # presumably M2 WU
		#"reload_height": 0.75,

		"primary_trigger": {
			
			"ammunition_type": &"ar magazine", # TO DO: how best to represent this? enum/int/&string/class/instance?
			"max_count": 52, # was: rounds_per_magazine
			"current_count": 52,
			
			"projectile_type": &"rifle bullet", # type of Projectile created (for fusion pistol the type of projectile created depends on which trigger is fired)
			"burst_count": 0, # 10 for shotgun, 2 for flechette; pretty sure this is no. of Projectiles fired by a single bullet, but need to check if this is added to 1 or is `min(1,burst_count)`
			"theta_error": 7.03125, # projectile's accuracy
			# offset from Player's center to Projectile's origin # TO DO: this is M2 WU(?) - update to Godot dimensions
			"dx": 0.0,
			"dz": -0.01953125,
			"recoil_magnitude": 0.0048828125, # applies backward impulse to Player
			#"shell_casing_type": 0, # pistol, AR primary, flechette # TO DO: this is purely cosmetic so belongs in WeaponInHand's shoot animation
			
			# timings affect Weapon/WeaponTrigger behavior so remain here; the corresponding weapon-in-hand animations should not exceed these timings to avoid visual jitters when transitioning from one animation to another
			"ready_ticks": 15 / 60, # (Classic MacOS used 60tick/sec)
			"ticks_per_round": 0 / 60, # null, # TO DO: why is this originally null, not 0?
			"recovery_ticks": 0 / 60,
			"charging_ticks": 0 / 60,
			
			# TO DO: probably just need a single "reload_time" - the other 2 values are for pausing before/after the Classic reload animation but that delay can be built into the weapon animations
			"await_reload_ticks": 10 / 60,
			"loading_ticks": 10 / 60,
			"finish_loading_ticks": 10 / 60,
			#"powerup_ticks": 0, # is always 0 so presumably we don't need it
			
			# TO DO: should we leave illumination to weapon assets? it is, arguably, a gameplay feature: in effect, Player momentarily acts as an omni-/semi-directional light source illuminating both weapon-in-hand model and the local environment (lights up the room); while the WiH glow is a visual effect the environment illumination is a gameplay feature (i.e. user may fire a gun to see in a pitch-black environment) so there is an argument for keeping it here and signalling to Player to emit light flash/emit light directly; OTOH, leaving WeaponInHand to manage the shoot light source (which it currently does) simplifies engine code
			"firing_light_intensity": 0.75,
			"firing_intensity_decay_ticks": 6,
			# TO DO: also allow Color to be specified, e.g. yellowish-white for magnum and AR primary; bluish-white for fusion; saturated orange for flamethrower and alien gun
		},
		
		"secondary_trigger": {
			
			"ammunition_type": &"ar grenade magazine",
			"max_count": 7,
			"current_count": 7,
			

			"projectile_type": &"grenade",
			"burst_count": 0,
			"theta_error": 0.0,
			"dx": 0.0,
			"dz": -0.09765625,
			"recoil_magnitude": 0.0390625,
			
			"ready_ticks": 15 / 60,
			"ticks_per_round": 5 / 60,
			"recovery_ticks": 17 / 60,
			"charging_ticks": 0 / 60,
			"await_reload_ticks": 10 / 60,
			"loading_ticks": 10 / 60,
			"finish_loading_ticks": 10 / 60,
			#"powerup_ticks": 0, # is always 0 so presumably we don't need it
			
			# TO DO: ditto
			"firing_light_intensity": 0.75,
			"firing_intensity_decay_ticks": 6,
		}
	},
]


var arsenal = {} # TO DO: get rid of this (there are still some dependencies in other files)




var weapons := [] # Array of all Weapon instances; Weapon.count properties indicate if the player is carrying 0, 1, or 2 of each

var current_weapon: Weapon
var current_weapon_index := 0

var is_ready := true


func initialize_weapons(weapon_states: Array) -> void:
	weapons.clear()
	for state in weapon_states:
		var weapon = Weapon.new()
		weapon.configure(state)
		weapons.append(weapon)



func _ready() -> void:
	set_as_top_level(true)
	initialize_weapons(weapon_definitions)
	current_weapon = weapons[current_weapon_index]



# firing

func shoot_primary(origin: Vector3, aim: Vector3) -> void:
	if is_ready:
		current_weapon.shoot_primary(origin, aim)


func shoot_secondary(origin: Vector3, aim: Vector3) -> void:
	if is_ready:
		current_weapon.shoot_secondary(origin, aim)


# switch weapons

func __switch_weapon(search_func) -> void:
	# caution: this assumes at least one weapon is available
	if is_ready:
		var new_weapon = search_func.call()
		if new_weapon != current_weapon:
			is_ready = false
			current_weapon.deactivate()
			await get_tree().create_timer(current_weapon.ready_ticks).timeout
			current_weapon = new_weapon
			current_weapon.activate()
			await get_tree().create_timer(current_weapon.ready_ticks).timeout
			is_ready = true


func goto_previous_weapon() -> void:
	var search_func = func():
		while true:
			current_weapon_index -= 1
			if current_weapon_index < 0:
				current_weapon_index = weapons.size() - 1
			var weapon = weapons[current_weapon_index]
			if weapon.count:
				return weapon
	__switch_weapon(search_func)
	

func goto_next_weapon() -> void:
	var search_func = func():
		while true:
			current_weapon_index += 1
			if current_weapon_index == weapons.size():
				current_weapon_index = 0
			var weapon = weapons[current_weapon_index]
			if weapon.count:
				return weapon
	__switch_weapon(search_func)


