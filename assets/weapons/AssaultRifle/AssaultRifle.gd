extends WeaponInHand


# assets/weapons/AssaultRifle/AssaultRifle.gd


# TODO: diegetic magazine displays for all weapons except FIST (which has infinite "ammo") and ROCKET_LAUNCHER (which should have a heads-up targeting and ammo display that appears on HUD to make long-range aiming easier)
#
# https://www.youtube.com/watch?v=Xq0wgrCmnyw


# TODO: WeaponInHand scenes should provide muzzle-flash illuminations; these can be omnidirectional lights for simplicity and performed in "shoot" animations
#
# Classic muzzle-flash settings for AR:
#
#	"firing_light_intensity": 0.75,
#	"firing_intensity_decay_time": 6,
#	we can also add Color, e.g. yellowish-white for magnum and AR primary; bluish-white for fusion; saturated orange for flamethrower and alien gun


# TODO: these are from Classic weapon physics and, except for bob (which is TBD), are all superseded by model animations:
#"idle_height": 1.1666565,
#"bob_amplitude": 0.028564453,
#"idle_width": 0.5,
#"horizontal_amplitude": 0.0,
#"kick_height": 0.0625, # presumably M2 WU
#"reload_height": 0.75,



const WEAPON_TYPE := Enums.WeaponType.ASSAULT_RIFLE


@onready var secondary_animation := $SecondaryAnimation

# randomized sound effects

@onready var audio_primary   := $Weapon/Audio
@onready var audio_secondary := $Weapon/SecondaryAudio

const AUDIO_PRIMARY_SHOOT := [
	preload("res://assets/audio/weapon/37 rms - Assault Rifle Firing.wav"), # TODO: add slightly different alternative(s)?
]

const AUDIO_SECONDARY_SHOOT := [
	preload("res://assets/audio/weapon/38 rmx - Grenade Launcher Firing 1.wav"),
	preload("res://assets/audio/weapon/38 rmx - Grenade Launcher Firing 2.wav"), 
]


func __redraw_ammo_display() -> void:
	pass
	# print(self.__primary_magazine.count, "/", self.__primary_magazine.max_count, " ,  ", 
	#	self.__secondary_magazine.count, "/", self.__secondary_magazine.max_count)


func reset() -> void:
	secondary_animation.play("RESET")
	super.reset()


func shoot() -> void:
	super.shoot()
	audio_primary.stream = AUDIO_PRIMARY_SHOOT.pick_random()
	audio_primary.play()


func secondary_idle() -> void:
	# note: each trigger has its own idle method since AR can idle one while shooting other
	secondary_animation.play("RESET")

func secondary_shoot() -> void:
	secondary_animation.play("shoot") # AR has independent shoot and reload animations for each trigger
	audio_secondary.stream = AUDIO_SECONDARY_SHOOT.pick_random()
	audio_secondary.play()
	__redraw_ammo_display()

func secondary_empty() -> void:
	secondary_animation.play("empty")

func secondary_reload() -> void:
	secondary_animation.play("reload")
	__redraw_ammo_display()

