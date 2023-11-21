extends Node3D

# WeaponInHand.gd -- this implements standard API for performing weapon's animations

enum WeaponHandedness {
	PRIMARY, # for now, assume PRIMARY=left, SECONDARY=right
	SECONDARY,
	BOTH,
}

var __handedness := WeaponHandedness.PRIMARY


# all WiH scenes must implement the following API:


# TO DO: dual-wield weapons (fists, pistols, shotguns) should use a single WeaponInHand.tscn which can display left, right, or both hands

# Q. for dual wield, use left=primary and right=secondary? (implement it that way for now; we can always add a set_primary_hand(LEFT/RIGHT) method later if needed)


# TO DO: while WiH animations could send `animation_ended` notifications back to Weapon, we probably want to avoid that coupling and rely solely on the timings specified in the weapon_definition to trigger Weapon's state machine transitions (this means a weapon animation might be interrupted by a new animation, causing it to glitch visually; however, that is much less evil than tying weapon behavior to animations which would cause all sorts of timing problems in the engine)



# TO DO: Weapon will call this whenever number of dual-wield weapons to show on-screen changes; e.g. when Player picks up second magnum, when one weapon runs out of bullets and Player has no ammo left to reload it
func set_handedness(handedness: WeaponHandedness) -> void:
	__handedness = handedness



func swap_in() -> void: # called by Weapon when Player activates it
	# TO DO: fix the `swap_in` animation so that it starts with nothing visible on screen and ends with single pistol in its idle position
	# TO DO:  remove 4.4sec of dead time from animation (the swap in/out animations should be around 1sec)
	pass

func swap_out() -> void: # called by Weapon when Player deactivates it
	# TO DO: fix the `swap_out` animation so that it starts with single pistol in its idle position and ends with nothing visible on screen
	# TO DO:  remove 4.4sec of dead time from animation (the swap in/out animations should be around 1sec)
	pass

func idle() -> void: # resting state;
	pass

func shoot_primary() -> void:
	pass

func shoot_secondary() -> void:
	pass

func reload_primary() -> void:
	pass

func reload_secondary() -> void:
	pass
