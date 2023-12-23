extends Node


# engine/projectile/DetonationManager.gd -- global


var __detonation_classes := {}



func _ready() -> void:
	#print("DetonationManager initialize")
	for definition in DetonationDefinitions.DETONATION_DEFINITIONS:
		var detonation_class = DetonationClass.new()
		detonation_class.configure(definition)
		__detonation_classes[definition.detonation_type] = detonation_class



func detonation_class_for_type(detonation_type: Enums.DetonationType) -> DetonationClass:
	assert(detonation_type in __detonation_classes, "Unrecognized detonation_type: %s" % detonation_type)
	var detonation_class = __detonation_classes[detonation_type]
	return detonation_class





class DetonationClass extends Object:

	const Detonation = preload("Detonation.tscn")

	
	func configure(definition: Dictionary) -> void:
		pass
	
	
	func spawn(origin: Vector3, collider: Node3D, collidee: Node3D) -> void:
		# for now, there's a single Detonation.tscn that momentarily displays an orange sphere when "exploding"
		Detonation.instantiate().detonate(self, origin, collider, collidee)

