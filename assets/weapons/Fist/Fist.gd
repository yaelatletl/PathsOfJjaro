extends WeaponInHand


# assets/weapons/Fist/Fist.gd

# TO DO: it may be simpler to model fists as single-wield dual-mode WIH as they always appear as a pair, where [primary_]shoot/secondary_shoot determines which fist fires first and they are alternated here; one argument against this is if one hand changes to Action gesture: that will be easier to animate if each fist is independent (but we can't make the decision until/unless we implement Action gestures, as it's TBD if single-wield WIH should have their own Action hand built in or if the Action hand is independent of some/all WIH; e.g. if Action hand is holding pistol/shotgun, should it put it away before changing gesture or should the gesture include holding onto that weapon somehow while waiting to perform and performing the Action; e.g. when holding a Magnum, the Action hand could use the gun butt to press buttons [Q. but what about keycards/repair chips?], OTOH the shotgun is bulky and difficult to hold while performing an Action; ultimately we might just put the WIH away temporarily when changing to Action gesture, speeding up the deactivating animation so gameplay isn't visibly interrupted, and restoring the WIH equally quickly once the Action is done)


const WEAPON_TYPE   := Enums.WeaponType.FIST # concrete WIH classes MUST implement this



# (in practice, these should never be called as fists should never reload)
func reload() -> void:
	pass

func reload_other() -> void:
	pass
