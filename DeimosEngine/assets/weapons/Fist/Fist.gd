extends DualWeaponInHand


# weapons/Fist.gd


# two-handed weapon, which can show left, right, or both hands, depending on whether inventory contains 1 or 2 guns

# note: when player has 2 guns, always show both and automatically switch between them when repeat-firing (I can't think of any use case where a user with two weapons would only want to use one of them, so let's take full advantage of two-handed firing while simplifying the control scheme from holding down two keys to one)
#
# the user determines which hand fires first by using primary or secondary trigger to fire (e.g. to empty and reload one gun without firing the other, press its trigger key repeatedly to take single, not burst, shots)


const DUAL_OFFSET_X := 0.30


func _ready() -> void:
	super._ready()
	self.initialize(Enums.WeaponType.FIST, $PrimaryHand, $PrimaryAnimation, $SecondaryHand, $SecondaryAnimation, DUAL_OFFSET_X)
