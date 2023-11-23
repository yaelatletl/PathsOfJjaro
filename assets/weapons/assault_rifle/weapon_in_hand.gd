extends Node3D

# assault_rifle/WeaponInHand.gd -- this implements the standard API for performing weapon's animations; TO DO: is it worth defining this API in an abstract base class as part of engine?

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


func set_bullets_remaining(count: int) -> void:
	pass

# TO DO: for animating bobbing motions as player moves, define either a `move(gait)` method or separate stop+walk+sprint+crouch+swim methods

# TO DO: what about vertical look motions? (in Classic M2, the weapon moves down/up in camera as the camera looks up/down)


# weapon states

func idle() -> void: # weapon is doing nothing
	pass

func shoot_primary() -> void:
	pass

func shoot_secondary() -> void:
	pass

func reload_primary() -> void:
	pass

func reload_secondary() -> void:
	pass

func empty() -> void: # e.g. plays click sound
	pass

# fusion pistol only

func charging() -> void:
	pass

func charged() -> void: # TO DO: FusionPistol.gd can manage its own animation by setting timers (the pistol visibly shakes and beeps while charged, and the longer it remains charged the larger the shake; Q. should it give user a brief 1-2sec warning when it reaches critical?)
	pass

func exploding() -> void:
	pass
