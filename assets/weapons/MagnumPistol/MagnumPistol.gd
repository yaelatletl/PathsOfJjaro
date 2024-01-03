extends WeaponInHand


# assets/weapons/Pistol.gd -- two-handed weapon, which can show left, right, or both hands, depending on whether inventory contains 1 or 2 guns


# TODO: need 3 reloading animations for magnum pistol: the primary hand holding the gun to reload, the secondary hand holding the magazine only, and the secondary hand holding both magazine and other gun
#
# https://youtu.be/k4oCKctbyxE
#
# https://www.youtube.com/watch?v=_r0ITAeCrjA
#
# TODO: look for existing skeleton animations to reuse; someone else might have implemented this before

@onready var secondary_animation := $SecondaryAnimation

@onready var audio := $Weapon/Audio

const AUDIO_SHOOT := [
	preload("res://assets/audio/weapon/35 rmx - Magnum Firing 1.wav"),
	preload("res://assets/audio/weapon/35 rmx - Magnum Firing 2.wav"),
	preload("res://assets/audio/weapon/35 rmx - Magnum Firing 3.wav"), 
]



const WEAPON_TYPE   := Enums.WeaponType.MAGNUM_PISTOL


# TODO: how best to implement magazine displays?

func __redraw_ammo_display() -> void:
	pass
	# print(self.__primary_magazine.count, "/", self.__primary_magazine.max_count, "  ", 
	#		self.__secondary_magazine.count, "/", self.__secondary_magazine.max_count)


func move_to_center(instantly: bool = false) -> void:
	secondary_animation.play("RESET" if instantly else "moving_to_center")

func move_to_side(instantly: bool = false) -> void:
	secondary_animation.play("offset" if instantly else "moving_to_offset")



func shoot() -> void:
	super.shoot()
	audio.stream = AUDIO_SHOOT.pick_random()
	audio.play()

