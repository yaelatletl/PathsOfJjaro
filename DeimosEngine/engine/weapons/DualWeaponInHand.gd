extends WeaponInHand
class_name DualWeaponInHand


# TO DO: these transitions are why Weapon needs a state machine: weapon should be telling the WIH when a trigger's availability changes

func update_trigger_availability(is_primary_available: bool, is_secondary_available: bool) -> void: # temporary
	if is_primary_available != self.is_primary_available:
		self.primary_animation.play("idle" if is_primary_available else "RESET") # these do not play activate/deactivate as that really needs controlled by Weapon
	if is_secondary_available != self.is_secondary_available:
		self.secondary_animation.play("idle" if is_secondary_available else "RESET")
	super.update_trigger_availability(is_primary_available, is_secondary_available)
	if self.is_primary_available and self.is_secondary_available:
		self.primary_hand.position = Vector3(-self.dual_offset_x, 0, 0)
		self.secondary_hand.position = Vector3(+self.dual_offset_x, 0, 0)
	else:
		self.primary_hand.position = Vector3.ZERO
		self.secondary_hand.position = Vector3.ZERO



# dual-wield weapons can independently animate hands as magnums require 2-handed reloading and both magnums and shotguns may appear in single- or dual-wield configurations, depending on whether player has 1 or 2 guns and if one or both is loaded; TO DO: this design is TBD

func play_animation(track: String) -> void: # override the parent class's implementation of this
	if self.is_primary_available:
		self.primary_animation.play(track)
		print(self.name, ": animate primary: ", track)
	if self.is_secondary_available:
		self.secondary_animation.play(track)
		print(self.name, ": animate secondary: ", track)

