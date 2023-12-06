extends Node3D


# TO DO: abstract base class that implements API?

# TO DO: one-handed with single/dual-function; two-handed (which can show left, right, or both hands, depending on whether player has 1 or 2 guns; when player has 2 guns, always show both)


# weapons/assault_rifle/WeaponInHand.gd -- this implements the standard API for performing weapon's animations; TO DO: make this API signal-based so that engine can be tested with or without HUD attached and vice-versa


# TO DO: in M2, when player looks up/down the WiH visually moves down/up (M1 doesn't do this but we probably want to replicate the M2 effect - it doesn't change weapon behavior but it looks “more lifelike”); ignore this for now and figure how best to add it later (WiH may need rendered in its own viewport and overlaid via canvas layer to prevent weapon barrel clipping through walls, in which case the simplest solution is for Player to adjust its viewport positioning when vertical look angle changes)

# TO DO: for animating bobbing motions as player moves, define either a `move(gait)` method or separate stop+walk+sprint+crouch+swim methods

# TO DO: the WIH needs separately rendered from walls and composited into Viewport/HUD's CanvasLayer to fix the problem where barrels visually clip through nearby walls:
#
# https://godotforums.org/d/28766-better-way-to-handle-first-person-weapon-clipping
#
# https://www.youtube.com/watch?v=Nhx3-hViv-Y
#
# Q. how to simulate shadows? (is there any way to get environment light intensity at a spatial coordinate? if so, we could sample the light hue and intensity at a point on front of player's capsule body as seen from primary camera's viewport and apply that light when rendering the WIH in the second viewport); note: we might also adjust FOV on WIH view to exaggerate perspective shortening (we don't want a gun's barrel extending into the far distance; it should be squat almost to point of looking flattened out, reminiscent of Classic's flat WIH renderings)


enum WeaponHandedness {
	PRIMARY, # for now, assume PRIMARY=left, SECONDARY=right
	SECONDARY,
	BOTH,
}

var __handedness := WeaponHandedness.PRIMARY


# all WiH scenes must implement the following API:


# note: dual-wield weapons (fists, pistols, shotguns) should use a single WeaponInHand.tscn which can display left, right, or both hands


# TO DO: for dual wield WIH, engine should always map primary_trigger = left hand, secondary_trigger = right hand; we can add a `var dual_wield_left_hand_is_triggered_by:PRIMARY_TRIGGER/SECONDARY_TRIGGER` flag in Settings later, which tells WeaponInHand if shoot_primary plays the left-hand or right-hand animation, and vice-versa
#
# Q. can we set this reverse flag automatically? e.g. with gamepad and mouse, the left hand is always controlled by the left button; with touch screen, by whichever trigger button the user positions to left side of screen; keyboard is tricky though: if we can know the physical keys' layout then we can determine which trigger key is left of the other key (e.g. Left-Shift is to left of Spacebar), otherwise it'll need a checkbox to set the swap flag manually


# TO DO: while WiH animations could send `animation_ended` notifications back to Weapon, we probably want to avoid that coupling and rely solely on the timings specified in the weapon_definition to trigger Weapon's state machine transitions (this means a weapon animation might be interrupted by a new animation, causing it to glitch visually; however, that is much less evil than tying weapon behavior to animations which would cause all sorts of timing problems in the engine)

@onready var animations := $AnimationPlayer

@onready var audio_activate         := $Audio/Activate
@onready var audio_shoot_primary    := $Audio/ShootPrimary
@onready var audio_shoot_secondary  := $Audio/ShootSecondary
@onready var audio_reload_primary   := $Audio/ReloadPrimary
@onready var audio_reload_secondary := $Audio/ReloadSecondary
@onready var audio_empty            := $Audio/Empty




# TO DO: Weapon will call this whenever number of dual-wield weapons to show on-screen changes; e.g. when Player picks up second magnum, when one weapon runs out of bullets and Player has no ammo left to reload it
func set_handedness(handedness: WeaponHandedness) -> void:
	__handedness = handedness



func _ready() -> void:
	Global.weapon_activating.connect(activating)
	Global.weapon_activated.connect(activated) # TO DO: needed?
	Global.weapon_deactivating.connect(deactivating)
	#Global.weapon_deactivated.connect(deactivated) # TO DO: needed?
	Global.primary_trigger_fired.connect(shoot_primary)
	Global.secondary_trigger_fired.connect(shoot_secondary)
	Global.primary_trigger_reloaded.connect(reload_primary)
	Global.secondary_trigger_reloaded.connect(reload_secondary)
	Global.primary_trigger_clicked.connect(empty_primary)
	Global.secondary_trigger_clicked.connect(empty_secondary)
	Global.primary_magazine_count_changed.connect(update_primary_magazine_display)
	Global.secondary_magazine_count_changed.connect(update_secondary_magazine_display)
	Global.weapon_detonated.connect(explode)
	
	


func activating(weapon: Weapon) -> void: # called by Weapon when Player activates it
	print("ACTIVATING AR")
	animations.play("activate")
	audio_activate.play()

func activated(weapon: Weapon) -> void: # called by Weapon when Player activates it
	animations.play("idle")
	print("ACTIVATED AR")

func deactivating(weapon: Weapon) -> void: # called by Weapon when Player deactivates it
	# TO DO: fix the `swap_out` animation so that it starts with single pistol in its idle position and ends with nothing visible on screen
	# TO DO:  remove 4.4sec of dead time from animation (the swap in/out animations should be around 1sec)
	animations.play("deactivate")



# TO DO: how best to implement magazine displays?

func update_primary_magazine_display(magazine: WeaponTrigger.Magazine) -> void:
	pass

func update_secondary_magazine_display(magazine: WeaponTrigger.Magazine) -> void:
	pass



# weapon states

func idle() -> void: # weapon is doing nothing
	animations.play("idle")

func shoot_primary(successfully: bool) -> void:
	animations.play("shoot_primary")
	audio_shoot_primary.play()

func shoot_secondary(successfully: bool) -> void:
	animations.play("shoot_secondary")
	audio_reload_secondary.play()

func reload_primary(successfully: bool) -> void:
	animations.play("reload_primary")
	audio_reload_primary.play()

func reload_secondary(successfully: bool) -> void:
	animations.play("reload_secondary")
	audio_shoot_secondary.play()

func empty_primary() -> void:
	audio_empty.play()

func empty_secondary() -> void:
	audio_empty.play()



# fusion pistol only

func charging() -> void:
	pass

func charged() -> void: # TO DO: FusionPistol.gd can manage its own animation by setting timers (the pistol visibly shakes and beeps while charged, and the longer it remains charged the larger the shake; Q. should it give user a brief 1-2sec warning when it reaches critical?)
	pass

func explode() -> void:
	pass

