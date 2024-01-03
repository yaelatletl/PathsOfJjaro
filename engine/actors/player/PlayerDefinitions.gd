extends Node


# TO DO: Boomer (Pfhor ship) maps have a low gravity flag, but I assume we can get the same effect by loading a different physics model for those levels? (really don't want lots of flag modifiers)



# TO DO: in 3D Physics layers, rename "Level" to Map/MapGeometry/Wall/Surface/Solid/Exterior/Architecture/Shell or something else that's descriptive as "Level" is unhelpful (in mapping terms, a Level is the map geometry *and* all of the objects inside it)

# TO DO: Player currently uses CapsuleShape to detect floor; at what point does capsule slide off a ledge? (not sure what M2's collision cylinder does - it might remain on ledge as long as any part of its base remains in contact; capsule is useful as it can push player out from wall so the model doesn't appear to slide down wall partly embedded in it; we might want to add a smaller cylinder to bottom of capsule to widen it a bit; also need to decide on player's Projectile/Explosion hit box, which may be a slightly narrower capsule or cylinder; there is also Player-NPC collisions to consider, which may need a wider collision cylinder to prevent NPC models' extremities appearing embedded in Player when both bodies are very close/touching)


# TO DO: these were copied from M3 physics so need converted to Godot quantities; most properties have yet to be connected to implementation


const INPUT_AXIS_MULTIPLIER := 15 # temporary until we decide on final values in physics dictionaries below



const CRAWL_PHYSICS := {
	"maximum_forward_velocity": 0.5 * INPUT_AXIS_MULTIPLIER, # 0.07142639, # TO DO: for now, multiply all velocity-related fields by 14 to get values relative to forward walk speed (we can figure out the final multiplier to emulate M2 speeds later)
	"maximum_backward_velocity": 0.3 * INPUT_AXIS_MULTIPLIER, # 0.05882263,
	"maximum_perpendicular_velocity": 0.3 * INPUT_AXIS_MULTIPLIER, # 0.049987793,
	
	"max_step_height": 0.5, # TO DO: what should this be when crawling?
	"max_jump_height": 0.0, # auto-jump is only available when sprinting
	
	"gravity":         10.0, # Gravity force #45 is okay, don't change it 
	"air_friction":    50.0, # TO DO: think this is airborne_deceleration
	"floor_friction":  250.0, # probably acceleration/deceleration below?
	"mass":            45.0, # think this is only used for imparting impulse to other movable bodies (elastic collisions); presumably all other objects must have a `mass` property too (RigidBody3D has `mass` property built in)
	
	
	# TO DO: these are currently ignored
	
	"acceleration": 0.004989624,
	"deceleration": 0.009994507,
	"climbing_acceleration": 0.003326416,
	
	"angular_acceleration": 0.625,
	"angular_deceleration": 1.25,
	"maximum_angular_velocity": 6.0,
	"angular_recentering_velocity": 0.75,
	
	# Player is built to 0.5m radius + 1.6m height (1.0m when crouched), then scaled to 96% to allow clearance in tight corridors
	#"radius": 0.25,
	#"height": 0.7999878,
	#"camera_height": 0.19999695,
	"splash_height": 0.5,
	
	# will the following be same for all gaits? what about swimming?
	
	"airborne_deceleration": 0.005554199, # applies to xz plane (AFAIK)
	"gravitational_acceleration": 0.0024871826, # applies to y axis
	"terminal_velocity": 0.14285278, # applies to y-axis 
	"external_deceleration": 0.004989624, # not sure about this: friction acting against xz motion?
	"external_angular_deceleration": 0.33332825, # not sure
	
	#"fast_angular_velocity": 21.333328, # head turn, so ignore it (strafing's the usual tactic for spraying bullets in one direction while moving in another and doesn't need extra keys)
	#"fast_angular_maximum": 128.0,
	
	# camera bob, I think
	"step_delta": 0.049987793, # units? (looks like seconds? it's not ticks) M2 uses the exact same camera bounce at both walk and sprint; not sure if we want walk to have slightly different bounce to visually differentiate gaits; crawl and swim will use different values; what about low-gravity?; TO DO: should we use M2 Physics params or hardcoded AnimationPlayer tracks to control camera bounce? (AP has advantage that play only needs called at transitions whereas code-based bounce requires extra code in _physics_process to update it; one advantage of code is when player stops at any point in bounce: animation track has to run to end of sequence to reset height, although we could use AP and switch to a timer-based function to reduce current bounce height)
	"step_amplitude": 0.099990845,
	
	#"dead_height": 0.25,
	#"half_camera_separation": 0.03125, # FOV
	#"maximum_elevation": 42.666656, # vertical look limit (±42.7deg is the Classic value, which was determined less by gameplay than by need to avoid visual distortion due to the Classic renderer's lack of true verticals; while we probably want to constrain the angle to some degree to avoid changing gameplay too much - e.g. near-vertical look allows user unlimited freedom to snipe from ledges whereas Classic forced user to jump down to shoot monsters directly below - we might allow a somewhat greater angle, e.g. ±60-70deg, for a more modern gameplay feel)
}



const WALK_PHYSICS := {
	"maximum_forward_velocity": 1.0 * INPUT_AXIS_MULTIPLIER, # 0.07142639, # TO DO: for now, multiply all velocity-related fields by 14 to get values relative to forward walk speed (we can figure out the final multiplier to emulate M2 speeds later)
	"maximum_backward_velocity": 0.82 * INPUT_AXIS_MULTIPLIER, # 0.05882263,
	"maximum_perpendicular_velocity": 0.7 * INPUT_AXIS_MULTIPLIER, # 0.049987793,
	
	"max_step_height": 0.5, # this looks too low; M2 steps can be ~0.3WU, which is ~0.6m (Q. where is max step height 
	"max_jump_height": 0.0, # auto-jump is only available when sprinting
	
	"gravity":         10.0, # Gravity force #45 is okay, don't change it 
	"air_friction":    50.0, # TO DO: think this is airborne_deceleration
	"floor_friction":  250.0, # probably acceleration/deceleration below?
	"mass":            45.0, # think this is only used for imparting impulse to other movable bodies (elastic collisions); presumably all other objects must have a `mass` property too (RigidBody3D has `mass` property built in)
	
	
	# TO DO: these aren't currently hooked up
	
	"acceleration": 0.004989624,
	"deceleration": 0.009994507,
	"climbing_acceleration": 0.003326416,
	
	"angular_acceleration": 0.625, # I think this is y-axis rotation
	"angular_deceleration": 1.25, # ditto
	"maximum_angular_velocity": 6.0, # ditto
	"angular_recentering_velocity": 0.75, # TO DO: how quickly the camera vertically auto-recenters when moving forward/backward (note: moving sideways does not auto-recenter)
	
	
	#"radius": 0.25,
	#"height": 0.7999878,
	#"camera_height": 0.19999695,
	"splash_height": 0.5, # TO DO: I assume this puts waterline around waist when swimming on surface of liquid
	
	# will the following be same for all gaits? what about swimming?
	
	"airborne_deceleration": 0.005554199, # applies to xz plane (AFAIK)
	"gravitational_acceleration": 0.0024871826, # applies to y axis
	"terminal_velocity": 0.14285278, # applies to y-axis 
	"external_deceleration": 0.004989624, # not sure about this: friction acting against xz motion?
	"external_angular_deceleration": 0.33332825, # not sure
	
	#"fast_angular_velocity": 21.333328, # head turn, so ignore it (strafing's the usual tactic for spraying bullets in one direction while moving in another and doesn't need extra keys)
	#"fast_angular_maximum": 128.0,
	
	# camera bob, I think
	"step_delta": 0.049987793, # units? (looks like seconds? it's not ticks) M2 uses the exact same camera bounce at both walk and sprint; not sure if we want walk to have slightly different bounce to visually differentiate gaits; crawl and swim will use different values; what about low-gravity?; TO DO: should we use M2 Physics params or hardcoded AnimationPlayer tracks to control camera bounce? (AP has advantage that play only needs called at transitions whereas code-based bounce requires extra code in _physics_process to update it; one advantage of code is when player stops at any point in bounce: animation track has to run to end of sequence to reset height, although we could use AP and switch to a timer-based function to reduce current bounce height)
	"step_amplitude": 0.099990845,
	
	#"dead_height": 0.25,
	#"half_camera_separation": 0.03125, # FOV
	#"maximum_elevation": 42.666656, # vertical look limit (±42.7deg is the Classic value, which was determined less by gameplay than by need to avoid visual distortion due to the Classic renderer's lack of true verticals; while we probably want to constrain the angle to some degree to avoid changing gameplay too much - e.g. near-vertical look allows user unlimited freedom to snipe from ledges whereas Classic forced user to jump down to shoot monsters directly below - we might allow a somewhat greater angle, e.g. ±60-70deg, for a more modern gameplay feel)
}



const SPRINT_PHYSICS := {
	"maximum_forward_velocity": 1.75 * INPUT_AXIS_MULTIPLIER * 1.3, # 0.125, # TO DO: check Player.linear_velocity is increased by 175% when sprinting vs walking (currently sprinting feels a bit slow)
	"maximum_backward_velocity": 1.16 * INPUT_AXIS_MULTIPLIER * 1.3, # 0.08332825,
	"maximum_perpendicular_velocity": 1.08 * INPUT_AXIS_MULTIPLIER * 1.3, # 0.076919556,
	
	"max_step_height": 0.5, # this looks too low; M2 steps can be ~0.3WU, which is ~0.6m (Q. where is max step height 
	"max_jump_height": 0.78, # see also StepDetector origin and target positions; this should not exceed that
	
	"gravity":         10.0, # Gravity force #45 is okay, don't change it 
	"air_friction":    50.0, # TO DO: think this is airborne_deceleration
	"floor_friction":  250.0, # probably acceleration/deceleration below?
	"mass":            45.0, # think this is only used for imparting impulse to other movable bodies (elastic collisions); presumably all other objects must have a `mass` property too (RigidBody3D has `mass` property built in)
	
	"acceleration": 0.009994507,
	"deceleration": 0.019989014,
	"climbing_acceleration": 0.004989624,
	
	"angular_acceleration": 1.25,
	"angular_deceleration": 2.5,
	"maximum_angular_velocity": 10.0,
	"angular_recentering_velocity": 1.5,
	
	#"radius": 0.25,
	#"height": 0.7999878,
	#"camera_height": 0.19999695,
	"splash_height": 0.5,
	
	# same for all gaits?
	
	"airborne_deceleration": 0.005554199,
	"gravitational_acceleration": 0.0024871826,
	"terminal_velocity": 0.14285278,
	"external_deceleration": 0.004989624,
	"external_angular_deceleration": 0.33332825,
	
	#"fast_angular_velocity": 21.333328,
	#"fast_angular_maximum": 128.0,
	
	"step_delta": 0.049987793,
	"step_amplitude": 0.099990845,
	
	#"dead_height": 0.25,
	#"half_camera_separation": 0.03125,
	#"maximum_elevation": 42.666656,
}


