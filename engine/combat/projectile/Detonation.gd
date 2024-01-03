extends StaticBody3D # TO DO: what class should detonation effect (bullet, energy bolt, grenade, etc impact) use? AnimatedBody3D?

# Detonation.gd -- created by a projectile upon self-destructive impact (note: bullets and other projectiles that hit destructible glass and some destructible props, e.g. glass bottles, [usually?] do not explode on that impact but instead destroy the object and continue moving until they hit something else)


# TO DO: for radius-damage explosions (exploding grenade, missile, etc.) use a collision Area with spherical shape to detect all damageable bodies inside blast radius (probably the easiest way to detect them); caution: except for nuclear hard death, explosion radius damage must not penetrate walls so presumably we need some sort of raycast from explosion center to recipient's center to confirm the recipient should be hit by the blast (unfortunately RayCast3D doesn't have an option for projecting a 3D cylinder instead of a 1D line, so center-to-center detection will fail if recipient is 51% covered by a wall; dunno how best to deal with this - e.g. by using multiple rays or moving the ray side-to-side and up-and-down to 'scan' the recipient and estimate how protected it is); worth checking out too how M2 determined if partially wall-covered Player/NPCs should/shouldn't take damage (although it did have an easier job of it given its very simple level geometry and self-occluding portals)
#
# TO DO: if a detonation does point damage but no shrapnel damage (e.g. bullet hit), it only needs to animate the effect and deal damage on the collidee 
#
# TO DO: the exact animation played by a detonation object depends on the type of projectile AND the type of body it hits; e.g. a bullet riccochets off metal, playing spark animation, and pierces flesh, playing human/alien blood splash) 
#
# Q. should Detonations that do shrapnel damage be implemented as ShrapnelExplosion subclass? or should Detonation have a `shrapnelRadius` property where 0 = no shrapnel and >0 = shrapnel damage to everything in its area? Q. when a grenade hits an NPC does it do direct damage AND shrapnel damage to that NPC, or shrapnel damage only? (need to check AO code for this)

# TO DO: if using a mesh/billboard sprite to represent the explosion shape, if it hits underside of a shallow shelf (e.g. the elevator platform in the Gameplay_test map) the mesh will appear half beneath and half above the shelf - how can we create a smarter explosion that doesn't penetrate through solid surfaces (though can still extend around corners)? or can a cloud of particle effects handle this use case better than a solid mesh? more research needed



# TO DO: can/should damaging effects such as burning materials, electric sparks, cryogenic leaks be implemented as detonations? (non-damaging effects might be simpler done in their own class as they don't need Detonation's damage behaviors, though they may still need some collision detection to control their behavior, e.g. if a door closes on the effect or an NPC corpse falls on top of it that should hide/suspend/stop it so it isn't "spraying" through the solid body)


@onready var mesh := $MeshInstance3D # TBD: depends how we apply visual effects
@onready var col  := $CollisionShape3D




func _ready() -> void:
	pass



func detonate(detonation_class, origin, collider, collidee):
	Global.add_to_level(self)
	self.global_position = origin
	print("EXPLODE! ", self.global_position)
	await get_tree().create_timer(0.1).timeout
	queue_free()



func _on_Area_body_entered(body) -> void: # TO DO: only connect this if detonation_class.shrapnel_radius>0; if it does, set col.shape.radius and see if Godot automatically picks up all bodies within that radius and passes them here; if not, we'll need some other means to detect them
	
	# TO DO: how best to determine if body is in same room as explosion? one option is to raycast from one to other, although we don't want that to fail if the ray impinges on a trivial scenery object (e.g. a bottle or chair) or partial wall (e.g. if player is 51% hidden from the explosion by a low wall which blocks a simple center-to-center raycast, they should still receive damage). Q. Is there a way to raycast a 2D area instead of a point?
	# What we do NOT want is for an explosion on one side of a full wall damaging anything on the other side of that wall. (Only exception to this rule is a nuclear explosion, which passes through walls and damages everything inside its radius.)
	
	# TO DO: the Explosion instance should pass itself to every body that is passed here, and let the body itself decide how it responds to it
	
	body.hit_by_explosion(self)


