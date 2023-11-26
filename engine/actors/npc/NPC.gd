extends RigidBody3D


# for now, don't bother setting up audio: we'll define an NPCAudio class so different awake, walk/run footstep, jump, land, shoot primary/secondary, hit, die, etc, etc sounds can be defined for each NPCType; an NPCAudio instance can then be bound to the NPC and its animations which then call the NPCAudio's awake, chatter, footstep, shoot, etc methods to play a sound 

# as a stretch goal, unique sounds may also be defined directly on an NPC subclass or its animations, e.g. Bobs might have some unique behaviors such as randomly chatting to each another when two Bobs are standing close together with no hostiles nearby, but standard sounds should all go behind the NPCAudio class's standard API as we need to get that fully functioning before we start considering any stretch goal enhancements


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
