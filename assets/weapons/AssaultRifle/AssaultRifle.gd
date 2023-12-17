extends WeaponInHand


# assets/weapons/AssaultRifle/AssaultRifle.gd


# TO DO: WeaponInHand scenes should provide muzzle-flash illuminations; these can be omnidirectional lights for simplicity and performed in "shoot" animations
#
# Classic muzzle-flash settings for AR:
#
#	"firing_light_intensity": 0.75,
#	"firing_intensity_decay_time": 6,
#	we can also add Color, e.g. yellowish-white for magnum and AR primary; bluish-white for fusion; saturated orange for flamethrower and alien gun


# TO DO: these are from Classic weapon physics and, except for bob (which is TBD), are all superseded by model animations:
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
	preload("res://assets/audio/weapon/37 rms - Assault Rifle Firing.wav"), # TO DO: add slightly different alternative(s)?
]

const AUDIO_SECONDARY_SHOOT := [
	preload("res://assets/audio/weapon/38 rmx - Grenade Launcher Firing 1.wav"),
	preload("res://assets/audio/weapon/38 rmx - Grenade Launcher Firing 2.wav"), 
]

# these methods are called by animations

func play_primary_shoot() -> void:
	audio_primary.stream = AUDIO_PRIMARY_SHOOT.pick_random()
	audio_primary.play()

func play_secondary_shoot() -> void:
	audio_secondary.stream = AUDIO_SECONDARY_SHOOT.pick_random()
	audio_secondary.play()




# TO DO: diegetic magazine displays for all weapons except FIST (which has infinite "ammo") and ROCKET_LAUNCHER (which should have a heads-up targeting and ammo display that appears on HUD to make long-range aiming easier)

func update_ammo(primary_magazine: Weapon.Magazine, secondary_magazine: Weapon.Magazine) -> void:
	print(primary_magazine.count, "/", primary_magazine.max_count, " ,  ", secondary_magazine.count, "/", secondary_magazine.max_count)


func reset() -> void:
	secondary_animation.play("RESET")
	super.reset()




func secondary_idle() -> void: # keep reset and idle separate for each trigger (AR can idle one while shooting other)
	secondary_animation.play("RESET")

func secondary_shoot() -> void:
	secondary_animation.play("shoot") # AR has independent shoot and reload animations for each trigger

func secondary_empty() -> void:
	secondary_animation.play("empty")

func secondary_reload() -> void:
	secondary_animation.play("reload")

