extends RigidBody3D
class_name Prop
# a non-fixed scenery object, e.g. stool, bottle; it can be knocked over, pushed around; it may optionally be destructible
@export var custom_physics : bool = false 
# if true, the object will not be affected by ordinary physics, but by custom integrator

