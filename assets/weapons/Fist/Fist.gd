extends WeaponInHand


# assets/weapons/Fist/Fist.gd


const WEAPON_TYPE   := Enums.WeaponType.FIST
const DUAL_OFFSET_X := 0.30


# (in practice, these should never be called as fists should never reload)
func reload() -> void:
	pass

func reload_other() -> void:
	pass
