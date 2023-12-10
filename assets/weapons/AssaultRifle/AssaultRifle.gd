extends WeaponInHand


# AssaultRifle.gd


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


# all WiH scenes must implement the following API:


# note: dual-wield weapons (fists, pistols, shotguns) should use a single WeaponInHand.tscn which can display left, right, or both hands


# TO DO: for dual wield WIH, engine should always map primary_trigger = left hand, secondary_trigger = right hand; we can add a `var dual_wield_left_hand_is_triggered_by:PRIMARY_TRIGGER/SECONDARY_TRIGGER` flag in Settings later, which tells WeaponInHand if shoot_primary plays the left-hand or right-hand animation, and vice-versa
#
# Q. can we set this reverse flag automatically? e.g. with gamepad and mouse, the left hand is always controlled by the left button; with touch screen, by whichever trigger button the user positions to left side of screen; keyboard is tricky though: if we can know the physical keys' layout then we can determine which trigger key is left of the other key (e.g. Left-Shift is to left of Spacebar), otherwise it'll need a checkbox to set the swap flag manually



# TO DO: this will be cleaner if both AnimationPlayers are moved to top level and always named $PrimaryAnimation and $SecondaryAnimation

func _ready() -> void:
	super._ready()
	self.initialize(Enums.WeaponType.ASSAULT_RIFLE, $PrimaryHand, $PrimaryAnimation, $PrimaryHand, $SecondaryAnimation)



# TO DO: how best to implement magazine displays?

func update_primary_magazine_display(magazine: WeaponTrigger.Magazine) -> void:
	print("update_primary_magazine_display ", magazine)

func update_secondary_magazine_display(magazine: WeaponTrigger.Magazine) -> void:
	print("update_secondary_magazine_display ", magazine)

