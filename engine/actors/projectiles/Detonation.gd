extends RigidBody3D # TO DO: StaticBody3D?


# Explosion.gd -- this was Grenade.gd, but that class mixed projectile behavior with explosion behavior and it's probably simpler to use a separate scene with its own collision object, animation, viewport/canvas layer effects, etc


# TO DO: for radius-damage explosions (exploding grenade, missile, etc.) use a collision Area with spherical shape to detect all damageable bodies inside blast radius (probably the easiest way to detect them); caution: except for nuclear hard death, explosion radius damage must not penetrate walls so presumably we need some sort of raycast from explosion center to recipient's center to confirm the recipient should be hit by the blast (unfortunately RayCast3D doesn't have an option for projecting a 3D cylinder instead of a 1D line, so center-to-center detection will fail if recipient is 51% covered by a wall; dunno how best to deal with this - e.g. by using multiple rays or moving the ray side-to-side and up-and-down to 'scan' the recipient and estimate how protected it is); worth checking out too how M2 determined if partially wall-covered Player/NPCs should/shouldn't take damage (although it did have an easier job of it given its very simple level geometry and self-occluding portals)



# TO DO: if Explosion does no shrapnel damage, it only needs to animate (the exact animation depends on both projectile type and what it hits, e.g. a bullet riccochets off metal, playing spark animation, and pierces flesh, playing human/alien blood splash) and apply damage to the object it impacted; it doesn't need a collision sphere; Q. should Explosions that do shrapnel damage be implemented as ShrapnelExplosion subclass of concrete Explosion? or just include `var shrapnelRadius` where 0 = no shrapnel? for now, ignore shrapnel damage entirely and focus on getting Weapon -> Projectile -> Explosion working



#var bodies_to_explode : Array = [] # TO DO: get rid of this

@export var impulse: float = 10

#func explode() -> void: # TO DO: 
#	for body in bodies_to_explode:
#		if body is RigidBody3D:
#			body.apply_central_impulse((body.global_transform.origin - global_transform.origin).normalized() * impulse)
#		elif body is CharacterBody3D:
#			if body.has_method("_get_component"):
				#body._get_component("movement_basic").add_impulse((body.global_transform.origin - global_transform.origin).normalized() * impulse)
		#body._damage(damage, Pooling.DAMAGE_TYPE.EXPLOSIVE)


#func stop() -> void:
#	sleeping = true
#	linear_velocity = Vector3.ZERO
#	angular_velocity = Vector3.ZERO
#	explode()
#	for exeptions in get_collision_exceptions():
#		remove_collision_exception_with(exeptions)
#	emit_signal("request_destroy")



func _on_Area_body_entered(body) -> void: # TO DO: only connect this if explosion has a shrapnel radius
	
	# TO DO: how best to determine if body is in same room as explosion? one option is to raycast from one to other, although we don't want that to fail if the ray impinges on a trivial scenery object (e.g. a bottle or chair) or partial wall (e.g. if player is 51% hidden from the explosion by a low wall which blocks a simple center-to-center raycast, they should still receive damage). Q. Is there a way to raycast a 2D area instead of a point?
	# What we do NOT want is for an explosion on one side of a full wall damaging anything on the other side of that wall. (Only exception to this rule is a nuclear explosion, which passes through walls and damages everything inside its radius.)
	
	# TO DO: the Explosion instance should pass itself to every body that is passed here, and let the body itself decide how it responds to it
#	var imp = (body.global_transform.origin - global_transform.origin).normalized() * impulse
#	if body is RigidBody3D: # TO DO: it makes more sense to
#		body.apply_central_impulse(imp)
#	elif body is CharacterBody3D:
#		body._get_component("movement_basic").add_impulse(imp)
		#body._damage(damage, Pooling.DAMAGE_TYPE.EXPLOSIVE)
	
	body.hit_by_explosion(self)
	
	# TO DO: ignoring objects it can't collide with is what collision_mask is for, so make sure they're set up correctly
	#if body.has_method("is_projectile"):
		#if body.type == type:
		#	return
	
	# these last few lines are for collecting damageable objects (e.g. player, enemies) found within the blast radius
	#bodies_to_explode.append(body)
	
	

#func _on_Area_body_exited(body) -> void: # TO DO: this is probably unnecessary unless the explosion is modeled as an expanding shell (in M2, explosion damage is dealt instantaneously on all objects within the blast radius)
#	bodies_to_explode.erase(body)
