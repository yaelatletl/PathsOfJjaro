extends Object
class_name DetonationClass

#

# note: Object subclasses must be .free()d when no longer needed


func _init() -> void: # arguments passed to Object.new(...) are passed to _init(); while using Node._init(...) must not have required parameters or it will break .duplicate, .instantiate, attaching to scene tree in editor, etc (which call _init without args to make copies), that doesn't matter so much here as these classes are only instantiated in and for code
	pass


