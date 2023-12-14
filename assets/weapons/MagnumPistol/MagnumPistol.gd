extends WeaponInHand


# assets/weapons/Pistol.gd


# TO DO: need animations for the hand holding magazine when reloading; this needs two animations, one holding pistol and magazine, the other holding magazine only


@onready var audio := $Weapon/Audio

const AUDIO_SHOOT := [
	preload("res://assets/audio/weapon/35 rmx - Magnum Firing 1.wav"),
	preload("res://assets/audio/weapon/35 rmx - Magnum Firing 2.wav"),
	preload("res://assets/audio/weapon/35 rmx - Magnum Firing 3.wav"), 
]


# two-handed weapon, which can show left, right, or both hands, depending on whether inventory contains 1 or 2 guns

# note: when player has 2 guns, always show both and automatically switch between them when repeat-firing (I can't think of any use case where a user with two weapons would only want to use one of them, so let's take full advantage of two-handed firing while simplifying the control scheme from holding down two keys to one)
#
# the user determines which hand fires first by using primary or secondary trigger to fire (e.g. to empty and reload one gun without firing the other, press its trigger key repeatedly to take single, not burst, shots)



# TO DO: right (secondary) hand should be mirror of left (x-axis transform = -1); dual-wield scenes should probably omit the Secondary node and duplicate Primary node to create it in _ready; the secondary shoot and reload sequences; for pistol, which requires two-handed reloading, the secondary reload sequence might play the opposing hand's action (clasping new mag in forefinger and thumb and inserting it into the primary gun; this gives us a bit more flexibility in the new-mag hand as it should retain its gun while reloading the other so must dip out of view quickly and return holding the new mag; alternatively, it can dip out of view and be replaced by two hands in the other animation; however, we still have to restore to dual-wield idle which is probably easier if each hand is independent throughout)
#
# https://youtu.be/k4oCKctbyxE
#
# https://www.youtube.com/watch?v=_r0ITAeCrjA
#
# TO DO: look for existing skeleton + animations


# TO DO: need 3 reloading animations: the primary hand holding the gun to reload, the secondary hand holding the magazine only, and the secondary hand holding both magazine and other gun; TO DO: should the single-gun reload animation use both hands, or only the hand containing the gun? the latter has the advantage that the other hand can easily be visible=false

const WEAPON_TYPE   := Enums.WeaponType.MAGNUM_PISTOL
const DUAL_OFFSET_X := 0.3 # TO DO: should this be in Weapon physics?


# TO DO: how best to implement magazine displays?

func update_ammo(primary_magazine: WeaponTrigger.Magazine, _secondary_magazine: WeaponTrigger.Magazine) -> void:
	var capacity  := primary_magazine.max_count
	var remaining := primary_magazine.count
	print(remaining, "/", capacity)



func play_shoot() -> void:
	audio.stream = AUDIO_SHOOT.pick_random()
	audio.play()

